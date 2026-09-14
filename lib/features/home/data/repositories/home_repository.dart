import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/study_stats.dart';
import '../../../quiz/data/models/quiz.dart';
import '../models/course.dart';

/// Agrège les données de l'accueil (cours, progression, quiz recommandés).
class HomeData {
  const HomeData({
    required this.courses,
    required this.weekProgress,
    required this.recommendedQuizzes,
    required this.studyHoursLabel,
    required this.validatedCount,
    required this.streakDays,
  });

  final List<Course> courses;
  final double weekProgress; // 0..1
  final List<Quiz> recommendedQuizzes;
  final String studyHoursLabel;
  final int validatedCount;
  final int streakDays;
}

class HomeRepository {
  HomeRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<HomeData> load() async {
    final courses = await _loadCourses();
    final stats = await _loadStats();
    final quizzes = await _loadRecentQuizzes();
    return HomeData(
      courses: courses,
      weekProgress: stats.avgScore / 100,
      recommendedQuizzes: quizzes,
      studyHoursLabel: stats.studyHoursLabel,
      validatedCount: stats.validatedCount,
      streakDays: stats.streakDays,
    );
  }

  Future<List<Quiz>> _loadRecentQuizzes() async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return const [];
    try {
      final snap = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.quizzes)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs
          .map((d) => Quiz.fromMap(d.id, d.data()))
          .where((q) => q.questions.isNotEmpty)
          .take(4)
          .toList();
    } catch (e) {
      debugPrint('HomeRepository._loadRecentQuizzes: $e');
      return const [];
    }
  }

  /// Statistiques réelles calculées depuis les tentatives de quiz Firestore.
  Future<StudyStats> _loadStats() async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return StudyStats.empty;
    try {
      final snap = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.quizzes)
          .get();
      return StudyStats.fromAttemptDocs(
        snap.docs.map((d) => d.data()).toList(),
      );
    } catch (e) {
      debugPrint('HomeRepository._loadStats: $e');
      return StudyStats.empty;
    }
  }

  Future<List<Course>> listCourses({int limit = 40}) =>
      _loadCourses(limit: limit);

  Future<List<Course>> _loadCourses({int limit = 8}) async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return const [];
    try {
      final snap = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.courses)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList();
    } catch (e) {
      debugPrint('HomeRepository._loadCourses: $e');
      return const [];
    }
  }
}
