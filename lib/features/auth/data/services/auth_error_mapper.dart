import 'package:firebase_auth/firebase_auth.dart';

/// Traduit un code d'erreur Firebase en clé l10n + code brut.
class MappedAuthError {
  const MappedAuthError({required this.key, this.code});
  final String key;
  final String? code;
}

abstract final class AuthErrorMapper {
  static MappedAuthError fromAny(Object error) {
    if (error is FirebaseAuthException) return mapped(error);
    return const MappedAuthError(key: 'auth_generic_error');
  }

  static MappedAuthError mapped(FirebaseAuthException e) {
    final key = switch (e.code) {
      'invalid-email' => 'auth_invalid_email',
      'user-disabled' ||
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'auth_wrong_password',
      'email-already-in-use' => 'auth_email_in_use',
      'weak-password' => 'auth_weak_password',
      'network-request-failed' => 'auth_network_error',
      'too-many-requests' => 'auth_too_many',
      'requires-recent-login' => 'auth_requires_recent_login',
      'google-config-missing' || '10' || 'sign_in_failed' => 'auth_google_config',
      'google-signin-failed' ||
      'account-exists-with-different-credential' =>
        'auth_google_failed',
      'google-sign-in-cancelled' ||
      'web-context-canceled' ||
      'canceled' =>
        'auth_generic_error',
      _ => 'auth_generic_error',
    };
    return MappedAuthError(key: key, code: e.code);
  }

  static String message(FirebaseAuthException e) => mapped(e).key;
}
