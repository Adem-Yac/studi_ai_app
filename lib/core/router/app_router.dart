import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_settings.dart';
import '../../app/onboarding_page.dart';
import '../../app/splash_page.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/auth_flow_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/documents/data/models/study_document.dart';
import '../../features/documents/presentation/pages/document_detail_page.dart';
import '../../features/flashcards/data/models/flashcard_deck.dart';
import '../../features/flashcards/presentation/pages/flashcard_review_page.dart';
import '../../features/flashcards/presentation/pages/flashcards_hub_page.dart';
import '../../features/home/presentation/pages/courses_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/quiz/data/models/quiz.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/quiz/presentation/pages/quiz_result_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../di/injection.dart';

/// Rafraîchit GoRouter quand [AuthCubit] ou l'onboarding change.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._authCubit) {
    _sub = _authCubit.stream.listen((_) => notifyListeners());
    AppSettings.onboardingDone.addListener(notifyListeners);
  }

  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    AppSettings.onboardingDone.removeListener(notifyListeners);
    super.dispose();
  }
}

GoRouter createAppRouter({AuthCubit? authCubit}) {
  final auth = authCubit ?? getIt<AuthCubit>();
  final refresh = _RouterRefresh(auth);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onboarded = AppSettings.onboardingDone.value;
      final authState = auth.state;

      if (!onboarded) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (authState is AuthInitial) {
        return loc == '/splash' ? null : '/splash';
      }
      if (authState is AuthAuthenticated) {
        if (loc == '/splash' || loc == '/onboarding' || loc.startsWith('/auth')) {
          return '/home';
        }
        return null;
      }
      // Non authentifié.
      return loc.startsWith('/auth') ? null : '/auth';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => OnboardingPage(
          onFinished: () => AppSettings.setOnboardingDone(true),
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, _) => const AuthFlowPage(),
        routes: [
          GoRoute(
            path: 'forgot-password',
            builder: (_, _) => const ForgotPasswordPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, _) => const ProgressPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, state) => SearchPage(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: '/courses',
        builder: (_, _) => const CoursesPage(),
      ),
      GoRoute(
        path: '/subjects',
        builder: (_, _) => const SubjectsPage(),
      ),
      GoRoute(
        path: '/flashcards',
        builder: (context, state) {
          final extra = state.extra;
          String? topic;
          String? pdfId;
          if (extra is Map) {
            topic = extra['topic']?.toString();
            pdfId = extra['pdfId']?.toString();
          }
          return FlashcardsHubPage(initialTopic: topic, pdfId: pdfId);
        },
      ),
      GoRoute(
        path: '/flashcards/review',
        builder: (context, state) =>
            FlashcardReviewPage(deck: state.extra as FlashcardDeck),
      ),
      GoRoute(
        path: '/security',
        builder: (_, _) => const SecurityPage(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, _) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/document',
        builder: (context, state) =>
            DocumentDetailPage(document: state.extra as StudyDocument),
      ),
      GoRoute(
        path: '/quiz/play',
        builder: (context, state) => QuizPage(quiz: state.extra as Quiz),
      ),
      GoRoute(
        path: '/quiz/result',
        builder: (context, state) =>
            QuizResultPage(attempt: state.extra as QuizAttempt),
      ),
    ],
  );
}
