import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/gemini_service.dart';
import '../models/quiz.dart';

/// Génère et persiste les quiz (Gemini + Firestore). Aucun QCM fictif.
class QuizRepository {
  QuizRepository(
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
        .collection(FirestorePaths.quizzes);
  }

  Future<Quiz> generate({
    required String topic,
    int count = 5,
    Uint8List? pdfBytes,
  }) async {
    final generated = await _gemini.generateQuiz(
      topic: topic,
      count: count,
      pdfBytes: pdfBytes,
    );
    final questions = generated.map(QuizQuestion.fromGenerated).toList();
    if (questions.isEmpty) {
      throw const GeminiUnavailable('Le QCM généré est vide.');
    }
    final quiz = Quiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: topic,
      subject: topic,
      questions: questions,
      durationMin: (count * 1.2).ceil(),
      difficulty: S.difficultyMedium,
    );
    await _saveDefinition(quiz);
    await _touchCourse(quiz);
    return quiz;
  }

  Future<void> _saveDefinition(Quiz quiz) async {
    final col = _col();
    if (col == null) return;
    try {
      await col.doc(quiz.id).set({
        ...quiz.toMap(),
        'kind': 'definition',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('QuizRepository._saveDefinition: $e');
    }
  }

  Future<void> _touchCourse(Quiz quiz) async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return;
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.courses)
          .doc(quiz.id)
          .set({
        'title': quiz.title,
        'subject': quiz.subject,
        'chapter': 'Quiz · ${quiz.length} ${S.questionsCount}',
        'progress': 0.0,
        'colorIndex': 1,
        'updatedLabel': S.justNow,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('QuizRepository._touchCourse: $e');
    }
  }

  Future<Quiz?> getById(String id) async {
    final col = _col();
    if (col == null) return null;
    try {
      final snap = await col.doc(id).get();
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      final quiz = Quiz.fromMap(snap.id, data);
      return quiz.questions.isEmpty ? null : quiz;
    } catch (e) {
      debugPrint('QuizRepository.getById: $e');
      return null;
    }
  }

  Future<List<Quiz>> listRecent({int limit = 8}) async {
    final col = _col();
    if (col == null) return const [];
    try {
      final snap = await col.orderBy('createdAt', descending: true).limit(30).get();
      return snap.docs
          .map((d) => Quiz.fromMap(d.id, d.data()))
          .where((q) => q.questions.isNotEmpty)
          .take(limit)
          .toList();
    } catch (e) {
      debugPrint('QuizRepository.listRecent: $e');
      return const [];
    }
  }

  Future<void> saveAttempt(QuizAttempt attempt) async {
    final col = _col();
    if (col == null) return;
    try {
      await col.add({
        'kind': 'attempt',
        'title': attempt.quiz.title,
        'subject': attempt.quiz.subject,
        'score': attempt.percent,
        'correct': attempt.correct,
        'total': attempt.total,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('QuizRepository.saveAttempt: $e');
    }
  }
}
