import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_strings.dart';
import '../../features/documents/data/repositories/documents_repository.dart';
import '../../features/home/data/models/course.dart';
import '../../features/quiz/data/repositories/quiz_repository.dart';
import '../../features/search/data/search_repository.dart';
import '../di/injection.dart';

/// Ouvre un cours / un résultat de recherche vers le bon écran.
class StudyOpener {
  static Future<void> openCourse(BuildContext context, Course course) async {
    final docs = getIt<DocumentsRepository>();
    final byId = await docs.getById(course.id);
    if (byId != null && context.mounted) {
      context.push('/document', extra: byId);
      return;
    }
    final quiz = await getIt<QuizRepository>().getById(course.id);
    if (quiz != null && quiz.questions.isNotEmpty && context.mounted) {
      context.push('/quiz/play', extra: quiz);
      return;
    }
    final byTitle = await docs.findByTitle(course.title);
    if (byTitle != null && context.mounted) {
      context.push('/document', extra: byTitle);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.courseUnavailable)),
    );
  }

  static Future<void> openHit(BuildContext context, SearchHit hit) async {
    switch (hit.kind) {
      case 'document':
        if (hit.document != null) {
          context.push('/document', extra: hit.document);
        }
      case 'quiz':
        if (hit.quiz != null) {
          context.push('/quiz/play', extra: hit.quiz);
        }
      case 'flashcard':
        if (hit.deck != null) {
          context.push('/flashcards/review', extra: hit.deck);
        }
      case 'subject':
        context.push('/subjects');
      case 'course':
        if (hit.course != null) {
          await openCourse(context, hit.course!);
        }
      default:
        break;
    }
  }
}
