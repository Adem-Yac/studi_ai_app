import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../documents/data/models/study_document.dart';
import '../../flashcards/data/models/flashcard_deck.dart';
import '../../home/data/models/course.dart';
import '../../quiz/data/models/quiz.dart';
import '../../subjects/data/models/study_subject.dart';

class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    this.subtitle = '',
    this.course,
    this.document,
    this.quiz,
    this.subject,
    this.deck,
  });

  final String kind; // course | document | quiz | subject | flashcard
  final String id;
  final String title;
  final String subtitle;
  final Course? course;
  final StudyDocument? document;
  final Quiz? quiz;
  final StudySubject? subject;
  final FlashcardDeck? deck;
}

class SearchRepository {
  SearchRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _col(String name) {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    return _firestore.collection(FirestorePaths.users).doc(uid).collection(name);
  }

  Future<List<SearchHit>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final hits = <SearchHit>[];
    await Future.wait([
      _collectCourses(q, hits),
      _collectDocuments(q, hits),
      _collectQuizzes(q, hits),
      _collectSubjects(q, hits),
      _collectFlashcards(q, hits),
    ]);
    return hits;
  }

  bool _matches(String q, Iterable<String> fields) {
    for (final f in fields) {
      if (f.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  Future<void> _collectCourses(String q, List<SearchHit> hits) async {
    final col = _col(FirestorePaths.courses);
    if (col == null) return;
    try {
      final snap = await col.limit(40).get();
      for (final d in snap.docs) {
        final course = Course.fromMap(d.id, d.data());
        if (_matches(q, [course.title, course.subject, course.chapter])) {
          hits.add(SearchHit(
            kind: 'course',
            id: course.id,
            title: course.title,
            subtitle: course.subject,
            course: course,
          ));
        }
      }
    } catch (e) {
      debugPrint('SearchRepository.courses: $e');
    }
  }

  Future<void> _collectDocuments(String q, List<SearchHit> hits) async {
    final col = _col(FirestorePaths.documents);
    if (col == null) return;
    try {
      final snap = await col.limit(40).get();
      for (final d in snap.docs) {
        final doc = StudyDocument.fromMap(d.id, d.data());
        if (_matches(q, [doc.title, doc.fileName, doc.subject])) {
          hits.add(SearchHit(
            kind: 'document',
            id: doc.id,
            title: doc.title,
            subtitle: doc.fileName,
            document: doc,
          ));
        }
      }
    } catch (e) {
      debugPrint('SearchRepository.documents: $e');
    }
  }

  Future<void> _collectQuizzes(String q, List<SearchHit> hits) async {
    final col = _col(FirestorePaths.quizzes);
    if (col == null) return;
    try {
      final snap = await col.limit(40).get();
      for (final d in snap.docs) {
        final quiz = Quiz.fromMap(d.id, d.data());
        if (quiz.questions.isEmpty) continue;
        if (_matches(q, [quiz.title, quiz.subject])) {
          hits.add(SearchHit(
            kind: 'quiz',
            id: quiz.id,
            title: quiz.title,
            subtitle: quiz.subject,
            quiz: quiz,
          ));
        }
      }
    } catch (e) {
      debugPrint('SearchRepository.quizzes: $e');
    }
  }

  Future<void> _collectSubjects(String q, List<SearchHit> hits) async {
    final col = _col(FirestorePaths.subjects);
    if (col == null) return;
    try {
      final snap = await col.limit(40).get();
      for (final d in snap.docs) {
        final s = StudySubject.fromMap(d.id, d.data());
        if (_matches(q, [s.name])) {
          hits.add(SearchHit(
            kind: 'subject',
            id: s.id,
            title: s.name,
            subtitle: '',
            subject: s,
          ));
        }
      }
    } catch (e) {
      debugPrint('SearchRepository.subjects: $e');
    }
  }

  Future<void> _collectFlashcards(String q, List<SearchHit> hits) async {
    final col = _col(FirestorePaths.flashcards);
    if (col == null) return;
    try {
      final snap = await col.limit(40).get();
      for (final d in snap.docs) {
        final deck = FlashcardDeck.fromMap(d.id, d.data());
        if (deck.cards.isEmpty) continue;
        if (_matches(q, [deck.title, deck.subject])) {
          hits.add(SearchHit(
            kind: 'flashcard',
            id: deck.id,
            title: deck.title,
            subtitle: '${deck.length}',
            deck: deck,
          ));
        }
      }
    } catch (e) {
      debugPrint('SearchRepository.flashcards: $e');
    }
  }
}
