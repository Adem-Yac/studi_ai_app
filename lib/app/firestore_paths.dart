/// Chemins Firestore StudyAI (collections = tables, doc id = uid).
abstract final class FirestorePaths {
  /// Profil compte — doc `{uid}`
  static const users = 'users';

  /// Conversations IA — `users/{uid}/conversations/{convId}`
  static const conversations = 'conversations';

  /// Messages d'une conversation — `.../conversations/{id}/messages/{msgId}`
  static const messages = 'messages';

  /// Cours de l'utilisateur — `users/{uid}/courses/{courseId}`
  static const courses = 'courses';

  /// Documents PDF importés — `users/{uid}/documents/{docId}`
  static const documents = 'documents';

  /// Quiz générés / passés — `users/{uid}/quizzes/{quizId}`
  static const quizzes = 'quizzes';

  /// Matières — `users/{uid}/subjects/{id}`
  static const subjects = 'subjects';

  /// Paquets de flashcards — `users/{uid}/flashcards/{id}`
  static const flashcards = 'flashcards';

  /// Progression / statistiques — doc `{uid}`
  static const progress = 'progress';
}
