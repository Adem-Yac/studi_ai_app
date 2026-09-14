import 'package:firebase_auth/firebase_auth.dart';

/// Utilisateur applicatif (découplé du SDK Firebase).
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.studyField,
    this.isDemo = false,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? studyField;
  final bool isDemo;

  String get firstName {
    final n = displayName.trim();
    if (n.isEmpty) return '';
    return n.split(' ').first;
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? studyField,
  }) =>
      AppUser(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        studyField: studyField ?? this.studyField,
        isDemo: isDemo,
      );

  factory AppUser.fromFirebase(User user, {String? studyField}) => AppUser(
        uid: user.uid,
        displayName: (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : (user.email?.split('@').first ?? ''),
        email: user.email ?? '',
        photoUrl: user.photoURL,
        studyField: studyField,
      );
}
