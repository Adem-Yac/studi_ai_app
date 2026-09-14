import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// `true` après une initialisation Firebase réussie.
bool firebaseReady = false;

/// Initialise Firebase sans planter l'app si la config est absente
/// (ex: desktop, ou avant `flutterfire configure`).
Future<void> initFirebaseSafely() async {
  final supported = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  if (!supported) {
    firebaseReady = false;
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    firebaseReady = true;
  } catch (e, st) {
    debugPrint('Firebase init skipped: $e\n$st');
    firebaseReady = false;
  }
}
