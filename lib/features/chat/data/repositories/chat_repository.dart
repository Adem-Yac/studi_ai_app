import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/chat_message.dart';

/// Passerelle chat ↔ Gemini + persistance Firestore.
class ChatRepository {
  ChatRepository(
    this._gemini, {
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final GeminiService _gemini;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _activeConvId = 'current';

  bool get aiAvailable => _gemini.isAvailable;

  CollectionReference<Map<String, dynamic>>? _messagesCol() {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.conversations)
        .doc(_activeConvId)
        .collection(FirestorePaths.messages);
  }

  Future<List<ChatMessage>> loadHistory() async {
    final col = _messagesCol();
    if (col == null) return const [];
    try {
      final snap = await col.orderBy('createdAt').limit(80).get();
      return snap.docs
          .map((d) => ChatMessage.fromMap(d.id, d.data()))
          .where((m) => m.text.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('[StudyAI] loadHistory: $e');
      return const [];
    }
  }

  Future<void> persist(ChatMessage message) async {
    final col = _messagesCol();
    if (col == null || message.pending || message.text.trim().isEmpty) return;
    try {
      await col.doc(message.id).set({
        ...message.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore
            .collection(FirestorePaths.users)
            .doc(uid)
            .collection(FirestorePaths.conversations)
            .doc(_activeConvId)
            .set({
          'updatedAt': FieldValue.serverTimestamp(),
          'preview': message.text.length > 120
              ? '${message.text.substring(0, 120)}…'
              : message.text,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[StudyAI] persist chat: $e');
    }
  }

  Future<void> clearHistory() async {
    final col = _messagesCol();
    if (col == null) return;
    try {
      final snap = await col.limit(200).get();
      final batch = _firestore.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[StudyAI] clearHistory: $e');
    }
  }

  Future<String> send(List<ChatMessage> history, String text) async {
    final turns = history
        .where((m) => !m.pending && m.text.trim().isNotEmpty)
        .map((m) => AiTurn(fromUser: m.fromUser, text: m.text))
        .toList();
    return _gemini.chat(turns, text);
  }

  Future<String> runAction(String label, String content) {
    return switch (label) {
      'summarize' => _gemini.summarize(content),
      'explain' => _gemini.explain(content),
      'translate' => _gemini.translate(content),
      _ => _gemini.generateText('$label:\n\n$content'),
    };
  }
}
