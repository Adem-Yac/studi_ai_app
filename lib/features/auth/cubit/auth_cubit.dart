import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_settings.dart';
import '../../../app/firebase_bootstrap.dart';
import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_error_mapper.dart';

sealed class AuthState {
  const AuthState();
}

/// État initial (splash) — le cubit n'a pas encore tranché.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthEmailLoading extends AuthState {
  const AuthEmailLoading();
}

class AuthGoogleLoading extends AuthState {
  const AuthGoogleLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.messageKey, this.errorCode});
  final String? messageKey;
  final String? errorCode;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

bool authStateIsBusy(AuthState s) =>
    s is AuthEmailLoading || s is AuthGoogleLoading;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial()) {
    if (firebaseReady) {
      _subscription = _repository.authStateChanges().listen(_onAuthChanged);
    } else {
      // Firebase absent → écran de connexion (pas de faux compte).
      scheduleMicrotask(() {
        if (!isClosed && state is AuthInitial) {
          emit(const AuthUnauthenticated());
        }
      });
    }
  }

  final AuthRepository _repository;
  StreamSubscription<User?>? _subscription;

  AppUser? get currentUser {
    final s = state;
    return s is AuthAuthenticated ? s.user : null;
  }

  void _onAuthChanged(User? user) {
    if (authStateIsBusy(state)) return;
    if (user == null) {
      if (state is AuthUnauthenticated &&
          (state as AuthUnauthenticated).messageKey != null) {
        return;
      }
      emit(const AuthUnauthenticated());
      return;
    }
    _hydrateUser(user);
  }

  Future<void> _hydrateUser(User user) async {
    try {
      await _repository.applyRemotePreferences();
      final mapped = await _repository.mapUser(user);
      if (!isClosed) emit(AuthAuthenticated(mapped));
    } catch (_) {
      if (!isClosed) emit(AuthAuthenticated(AppUser.fromFirebase(user)));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!AuthRepository.isValidEmail(email)) {
      emit(const AuthUnauthenticated(messageKey: 'auth_invalid_email'));
      return;
    }
    if (password.trim().isEmpty) {
      emit(const AuthUnauthenticated(messageKey: 'auth_wrong_password'));
      return;
    }
    if (!firebaseReady) {
      emit(const AuthUnauthenticated(messageKey: 'auth_network_error'));
      return;
    }
    emit(const AuthEmailLoading());
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(await _repository.mapUser(user)));
      await persistPreferences();
    } catch (e) {
      final mapped = AuthErrorMapper.fromAny(e);
      emit(AuthUnauthenticated(messageKey: mapped.key, errorCode: mapped.code));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!AuthRepository.isValidEmail(email)) {
      emit(const AuthUnauthenticated(messageKey: 'auth_invalid_email'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthUnauthenticated(messageKey: 'auth_weak_password'));
      return;
    }
    if (!firebaseReady) {
      emit(const AuthUnauthenticated(messageKey: 'auth_network_error'));
      return;
    }
    emit(const AuthEmailLoading());
    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthAuthenticated(await _repository.mapUser(user)));
      await persistPreferences();
    } catch (e) {
      final mapped = AuthErrorMapper.fromAny(e);
      emit(AuthUnauthenticated(messageKey: mapped.key, errorCode: mapped.code));
    }
  }

  Future<void> signInWithGoogle() async {
    if (!firebaseReady) {
      emit(const AuthUnauthenticated(messageKey: 'auth_network_error'));
      return;
    }
    emit(const AuthGoogleLoading());
    try {
      final user = await _repository.signInWithGoogle();
      emit(AuthAuthenticated(await _repository.mapUser(user)));
      await persistPreferences();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-sign-in-cancelled' ||
          e.code == 'web-context-canceled' ||
          e.code == 'canceled') {
        emit(const AuthUnauthenticated());
        return;
      }
      final mapped = AuthErrorMapper.mapped(e);
      emit(AuthUnauthenticated(messageKey: mapped.key, errorCode: mapped.code));
    } catch (e) {
      final mapped = AuthErrorMapper.fromAny(e);
      emit(AuthUnauthenticated(messageKey: mapped.key, errorCode: mapped.code));
    }
  }

  /// Connexion anonyme Firebase (données réelles, liées à cet appareil).
  Future<void> continueAsGuest() async {
    if (!firebaseReady) {
      emit(const AuthUnauthenticated(messageKey: 'auth_network_error'));
      return;
    }
    emit(const AuthEmailLoading());
    try {
      final user = await _repository.signInAnonymously();
      emit(AuthAuthenticated(await _repository.mapUser(user)));
      await persistPreferences();
    } catch (e) {
      final mapped = AuthErrorMapper.fromAny(e);
      emit(AuthUnauthenticated(messageKey: mapped.key, errorCode: mapped.code));
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    if (!firebaseReady) return true;
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get hasPasswordProvider => _repository.hasPasswordProvider;
  bool get emailVerified => _repository.emailVerified;

  Future<String?> sendEmailVerification() async {
    try {
      await _repository.sendEmailVerification();
      return null;
    } catch (e) {
      return AuthErrorMapper.fromAny(e).key;
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return AuthErrorMapper.fromAny(e).key;
    }
  }

  Future<String?> deleteAccount({String? password}) async {
    try {
      await _repository.deleteAccount(password: password);
      emit(const AuthUnauthenticated());
      return null;
    } catch (e) {
      return AuthErrorMapper.fromAny(e).key;
    }
  }

  Future<void> signOut() async {
    if (firebaseReady) {
      try {
        await _repository.signOut();
      } catch (_) {}
    }
    emit(const AuthUnauthenticated());
  }

  void clearTransientMessage() {
    if (state is AuthUnauthenticated) emit(const AuthUnauthenticated());
  }

  void emitMismatch() =>
      emit(const AuthUnauthenticated(messageKey: 'auth_passwords_mismatch'));

  Future<void> updateProfile({
    required String displayName,
    String? studyField,
  }) async {
    if (state is! AuthAuthenticated) return;
    try {
      final user = await _repository.updateProfile(
        displayName: displayName,
        studyField: studyField,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      debugPrint('updateProfile: $e');
    }
  }

  Future<void> persistPreferences() async {
    try {
      await _repository.persistPreferences(
        lang: AppSettings.lang.value,
        theme: AppSettings.themeMode.value == ThemeMode.dark ? 'dark' : 'light',
        answerLevel: AppSettings.answerLevel.value.name,
        notifications: AppSettings.notificationsEnabled.value,
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
