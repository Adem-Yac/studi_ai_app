import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../app/firebase_bootstrap.dart';
import '../../../../app/firestore_paths.dart';

/// Profil étudiant Firestore (`users/{uid}`). Échecs réseau ignorés.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  Future<void> createOrUpdateProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? studyField,
    String? lang,
    String? theme,
    String? answerLevel,
    bool? notifications,
    List<String>? providers,
    bool? emailVerified,
  }) async {
    if (!firebaseReady) return;
    try {
      final data = <String, dynamic>{
        'uid': uid,
        'email': email,
        'displayName': displayName ?? '',
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (providers != null) data['providers'] = providers;
      if (emailVerified != null) data['emailVerified'] = emailVerified;
      if (studyField != null) data['studyField'] = studyField;
      if (lang != null) data['lang'] = lang;
      if (theme != null) data['theme'] = theme;
      if (answerLevel != null) data['answerLevel'] = answerLevel;
      if (notifications != null) data['notifications'] = notifications;

      final ref = _userDoc(uid);
      final exists = (await ref.get()).exists;
      if (!exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['plan'] = 'free';
        data['xp'] = 0;
      }
      await ref.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserRepository.createOrUpdateProfile: $e');
    }
  }

  Future<void> syncFromAuthUser(User user) => createOrUpdateProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        providers: user.providerData.map((p) => p.providerId).toList(),
        emailVerified: user.emailVerified,
      );

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    if (!firebaseReady) return null;
    try {
      final snap = await _userDoc(uid).get();
      return snap.data();
    } catch (e) {
      debugPrint('UserRepository.loadProfile: $e');
      return null;
    }
  }

  Future<void> deleteProfile(String uid) async {
    if (!firebaseReady) return;
    try {
      await _userDoc(uid).delete();
    } catch (e) {
      debugPrint('UserRepository.deleteProfile: $e');
    }
  }
}
