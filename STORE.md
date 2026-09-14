# StudyAI — checklist Play Store & App Store

L’app est maintenant branchée sur de vraies données (compte Firebase, chat Gemini, quiz, documents). Voici ce qu’il reste **côté comptes / legal / signatures** avant publication.

## Déjà en place dans le code

| Élément | Valeur |
|---|---|
| Nom affiché Android | `StudyAI` |
| Nom affiché iOS | `StudyAI` |
| Package Android | `com.studyai.studyai_app` |
| Bundle iOS | `com.studyai.studyaiApp` |
| Version | `1.0.0+1` (`pubspec.yaml`) |
| Icône | `assets/images/app_logo.png` |
| Internet Android | permission `INTERNET` |
| Textes iOS caméra / photos / micro | dans `Info.plist` |
| Auth | email/mot de passe, Google, invité anonyme |
| Données | Firestore + Storage (règles par utilisateur) |
| IA | Gemini (Firebase AI, sinon clé API locale) |

## Play Store (Android)

1. Compte [Google Play Console](https://play.google.com/console) (25 $ une fois).
2. Créer une **clé de signature** (keystore) — ne jamais la perdre :
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Puis `android/key.properties` (déjà gitignoré) :
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Brancher la signature release dans `android/app/build.gradle.kts` (aujourd’hui c’est encore la clé **debug**).
4. Build : `flutter build appbundle` (AAB, pas APK, pour le Play Store).
5. Fiche store : nom, description FR/EN, captures 1080×1920, icône 512×512, feature graphic 1024×500.
6. Classification du contenu, politique de confidentialité (URL publique), e-mail de contact.
7. Déclarer que l’app utilise l’IA / des données personnelles (compte, documents, conversations).

## App Store (iOS)

1. Compte [Apple Developer](https://developer.apple.com) (99 $/an).
2. Sur un **Mac** : ouvrir `ios/Runner.xcworkspace` dans Xcode.
3. Signing : Team Apple + certificat + profil Provisioning.
4. Bundle ID `com.studyai.studyaiApp` doit exister dans App Store Connect (et matcher Firebase iOS).
5. Build : `flutter build ipa` puis upload via Transporter / Xcode.
6. Privacy Nutrition Labels + politique de confidentialité.
7. Captures iPhone (6.7" et 6.1") + description.

## Compte / backend à finaliser

- [ ] Activer **Google Sign-In** dans Firebase Authentication + SHA-1 / SHA-256 du keystore **release** (Play).
- [ ] Créer le bucket **Firebase Storage** : [console Storage](https://console.firebase.google.com/project/studyai-app-9f3k2/storage) → Get Started. Ensuite : `firebase deploy --only storage`.
- [ ] Page **politique de confidentialité** (compte, PDFs, messages IA, Gemini).
- [ ] **Régénérer la clé Gemini** collée dans le chat (elle est exposée). La nouvelle clé va dans `lib/app/gemini_secrets.dart` (gitignoré) ou `--dart-define=GEMINI_API_KEY=...`.
- [ ] Pour la prod store : restreindre la clé Gemini (HTTP referrer / IP) ou passer uniquement par Firebase AI Logic.

## Ce que tu n’as plus à “simuler”

- Plus de cours / quiz / documents fictifs.
- Plus de chat “mode démo”.
- Plus de connexion fake : inscription, login et invité passent par Firebase.
- Progression et badges = quiz réellement passés.
