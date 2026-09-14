import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../app/app_settings.dart';
import '../../../../app/google_auth_config.dart';
import '../models/app_user.dart';
import 'user_repository.dart';

/// Authentification Firebase : email/password + Google Sign-In.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    UserRepository? userRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: GoogleAuthConfig.serverClientId,
            ),
        _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  static bool isValidEmail(String email) {
    final e = email.trim();
    if (e.isEmpty || e.length > 254) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } on PlatformException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await _userRepository.syncFromAuthUser(user);
      return user;
    });
  }

  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _guard(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await user.updateDisplayName(displayName.trim());
      try {
        await user.sendEmailVerification();
      } catch (e) {
        debugPrint('sendEmailVerification: $e');
      }
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        providers: const ['password'],
        emailVerified: user.emailVerified,
      );
      return user;
    });
  }

  Future<User> signInWithGoogle() async {
    return _guard(() async {
      try {
        return await _signInWithGoogleNative();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'google-sign-in-cancelled') rethrow;
        debugPrint('Google native sign-in failed: ${e.code} ${e.message}');
      } catch (e) {
        debugPrint('Google native sign-in failed: $e');
      }
      return _signInWithGoogleProvider();
    });
  }

  Future<User> _signInWithGoogleNative() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      debugPrint('GoogleSignIn PlatformException: ${e.code} ${e.message}');
      final code = e.code.toLowerCase();
      if (code.contains('cancel')) {
        throw FirebaseAuthException(code: 'google-sign-in-cancelled');
      }
      throw FirebaseAuthException(
        code: 'google-config-missing',
        message: e.message,
      );
    }
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'google-sign-in-cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(code: 'google-config-missing');
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'google-signin-failed');
    }
    await _persistGoogleProfile(user, googleUser);
    return user;
  }

  Future<User> _signInWithGoogleProvider() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});
    final cred = await _auth.signInWithProvider(provider);
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'google-signin-failed');
    }
    await _persistGoogleProfile(user, null);
    return user;
  }

  Future<void> _persistGoogleProfile(
    User user,
    GoogleSignInAccount? googleUser,
  ) {
    return _userRepository.createOrUpdateProfile(
      uid: user.uid,
      email: user.email ?? googleUser?.email ?? '',
      displayName: user.displayName ?? googleUser?.displayName,
      photoUrl: user.photoURL ?? googleUser?.photoUrl,
      providers: user.providerData.map((p) => p.providerId).toList(),
      emailVerified: true,
    );
  }

  Future<User> signInAnonymously() {
    return _guard(() async {
      final cred = await _auth.signInAnonymously();
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        email: '',
        displayName: 'Invité',
        providers: const ['anonymous'],
      );
      return user;
    });
  }

  Future<AppUser> mapUser(User user) async {
    final extra = await _userRepository.loadProfile(user.uid);
    return AppUser.fromFirebase(
      user,
      studyField: extra?['studyField']?.toString(),
    );
  }

  Future<AppUser> updateProfile({
    required String displayName,
    String? studyField,
  }) {
    return _guard(() async {
      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');
      await user.updateDisplayName(displayName.trim());
      await user.reload();
      final fresh = _auth.currentUser ?? user;
      await _userRepository.createOrUpdateProfile(
        uid: fresh.uid,
        email: fresh.email ?? '',
        displayName: displayName.trim(),
        studyField: studyField,
        photoUrl: fresh.photoURL,
      );
      return mapUser(fresh);
    });
  }

  Future<void> persistPreferences({
    required String lang,
    required String theme,
    String? answerLevel,
    bool? notifications,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _userRepository.createOrUpdateProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      lang: lang,
      theme: theme,
      answerLevel: answerLevel,
      notifications: notifications,
    );
  }

  Future<void> applyRemotePreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final extra = await _userRepository.loadProfile(user.uid);
    if (extra == null) return;
    final lang = extra['lang']?.toString();
    if (lang == 'fr' || lang == 'en' || lang == 'ar') {
      await AppSettings.setLang(lang!);
    }
    final theme = extra['theme']?.toString();
    if (theme == 'dark' || theme == 'light') {
      await AppSettings.setThemeMode(
        theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      );
    }
    final level = extra['answerLevel']?.toString();
    if (level != null) {
      final match = AnswerLevel.values.where((e) => e.name == level);
      if (match.isNotEmpty) {
        await AppSettings.setAnswerLevel(match.first);
      }
    }
    final notifs = extra['notifications'];
    if (notifs is bool) {
      await AppSettings.setNotificationsEnabled(notifs);
    }
  }

  Future<void> sendPasswordResetEmail(String email) => _guard(
        () => _auth.sendPasswordResetEmail(email: email.trim()),
      );

  bool get hasPasswordProvider =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'password') ??
      false;

  bool get emailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> sendEmailVerification() => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) throw FirebaseAuthException(code: 'user-not-found');
        await user.sendEmailVerification();
      });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _guard(() async {
        final user = _auth.currentUser;
        final email = user?.email;
        if (user == null || email == null || email.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }
        final cred = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
      });

  Future<void> deleteAccount({String? password}) => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) throw FirebaseAuthException(code: 'user-not-found');
        if (password != null &&
            password.isNotEmpty &&
            user.email != null &&
            user.email!.isNotEmpty) {
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(cred);
        }
        try {
          await _firestoreUserCleanup(user.uid);
        } catch (e) {
          debugPrint('deleteAccount cleanup: $e');
        }
        await user.delete();
      });

  Future<void> _firestoreUserCleanup(String uid) async {
    await _userRepository.deleteProfile(uid);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
