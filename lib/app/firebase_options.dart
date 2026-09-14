// GENERATED-LIKE PLACEHOLDER — remplace ce fichier en exécutant :
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Tant que les vraies valeurs ne sont pas renseignées, Firebase ne s'initialise
// pas (initFirebaseSafely capture l'erreur) et l'app fonctionne en mode dégradé.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plateforme non configurée. Lance `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABJ3pWOg32A3a7_vRgYYNIDlUYv1Qvi7I',
    appId: '1:332657220848:android:3f632c922c04e5e9bbb635',
    messagingSenderId: '332657220848',
    projectId: 'studyai-app-9f3k2',
    storageBucket: 'studyai-app-9f3k2.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZ_hdj9uJNc865N2FmivNjpSGbIUrhw7g',
    appId: '1:332657220848:ios:eca6b60101d158bbbbb635',
    messagingSenderId: '332657220848',
    projectId: 'studyai-app-9f3k2',
    storageBucket: 'studyai-app-9f3k2.firebasestorage.app',
    iosBundleId: 'com.studyai.studyaiApp',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCeVvkilgYoK8P52SSFaG0oCmUU1Ga4u8',
    appId: '1:332657220848:web:c790160f07b819d8bbb635',
    messagingSenderId: '332657220848',
    projectId: 'studyai-app-9f3k2',
    authDomain: 'studyai-app-9f3k2.firebaseapp.com',
    storageBucket: 'studyai-app-9f3k2.firebasestorage.app',
  );
}
