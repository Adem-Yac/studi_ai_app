import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';
import '../models/study_subject.dart';

class SubjectsRepository {
  SubjectsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (!firebaseReady || uid == null) return null;
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.subjects);
  }

  Future<List<StudySubject>> list() async {
    final col = _col();
    if (col == null) return const [];
    try {
      final snap = await col.orderBy('name').get();
      return snap.docs
          .map((d) => StudySubject.fromMap(d.id, d.data()))
          .where((s) => s.name.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('SubjectsRepository.list: $e');
      try {
        final col2 = _col();
        if (col2 == null) return const [];
        final snap = await col2.get();
        final items = snap.docs
            .map((d) => StudySubject.fromMap(d.id, d.data()))
            .where((s) => s.name.trim().isNotEmpty)
            .toList();
        items.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return items;
      } catch (e2) {
        debugPrint('SubjectsRepository.list fallback: $e2');
        return const [];
      }
    }
  }

  Future<StudySubject> create({required String name, int colorIndex = 0}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('empty');
    }
    final col = _col();
    final subject = StudySubject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed,
      colorIndex: colorIndex,
    );
    if (col != null) {
      await col.doc(subject.id).set({
        ...subject.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return subject;
  }

  Future<void> update(StudySubject subject) async {
    final col = _col();
    if (col == null) return;
    await col.doc(subject.id).set(subject.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    final col = _col();
    if (col == null) return;
    await col.doc(id).delete();
  }
}
