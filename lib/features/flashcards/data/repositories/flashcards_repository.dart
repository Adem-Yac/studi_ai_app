import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/flashcard_deck.dart';

class FlashcardsRepository {
  FlashcardsRepository(
    this._gemini, {
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final GeminiService _gemini;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.flashcards);
  }

  Future<List<FlashcardDeck>> list({int limit = 30}) async {
    final col = _col();
    if (col == null) return const [];
    try {
      final snap =
          await col.orderBy('createdAt', descending: true).limit(limit).get();
      return snap.docs
          .map((d) => FlashcardDeck.fromMap(d.id, d.data()))
          .where((d) => d.cards.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('FlashcardsRepository.list: $e');
      return const [];
    }
  }

  Future<FlashcardDeck> generate({
    required String topic,
    int count = 8,
    Uint8List? pdfBytes,
  }) async {
    final generated = await _gemini.generateFlashcards(
      topic: topic,
      count: count,
      pdfBytes: pdfBytes,
    );
    final cards = generated
        .map((c) => Flashcard(front: c.front.trim(), back: c.back.trim()))
        .where((c) => c.front.isNotEmpty && c.back.isNotEmpty)
        .toList();
    if (cards.isEmpty) {
      throw const GeminiUnavailable('Aucune flashcard générée.');
    }
    final deck = FlashcardDeck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: topic,
      subject: topic,
      cards: cards,
    );
    await _save(deck);
    return deck;
  }

  Future<void> _save(FlashcardDeck deck) async {
    final col = _col();
    if (col == null) return;
    try {
      await col.doc(deck.id).set({
        ...deck.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FlashcardsRepository._save: $e');
    }
  }

  Future<void> delete(String id) async {
    final col = _col();
    if (col == null) return;
    try {
      await col.doc(id).delete();
    } catch (e) {
      debugPrint('FlashcardsRepository.delete: $e');
    }
  }
}
