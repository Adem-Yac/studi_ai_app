import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../../../../core/services/study_stats.dart';
import '../models/progress_data.dart';

class ProgressRepository {
  ProgressRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<ProgressData> load() async {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return ProgressData.fromStats(StudyStats.empty);
    try {
      final snap = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.quizzes)
          .get();
      final stats = StudyStats.fromAttemptDocs(
        snap.docs.map((d) => d.data()).toList(),
      );
      return ProgressData.fromStats(stats);
    } catch (e) {
      debugPrint('ProgressRepository.load: $e');
      return ProgressData.fromStats(StudyStats.empty);
    }
  }
}
