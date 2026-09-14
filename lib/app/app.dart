import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/injection.dart';
import '../core/router/app_router.dart';
import '../features/auth/cubit/auth_cubit.dart';
import 'app_settings.dart';
import 'l10n/app_lang.dart';
import 'theme/app_theme.dart';

/// Messenger global : permet d'afficher un SnackBar qui survit à la navigation
/// (ex. confirmation d'inscription juste avant la redirection vers /home).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class StudyAIApp extends StatefulWidget {
  const StudyAIApp({super.key});

  @override
  State<StudyAIApp> createState() => _StudyAIAppState();
}

class _StudyAIAppState extends State<StudyAIApp> {
  late final AuthCubit _authCubit = getIt<AuthCubit>();
  late final _router = createAppRouter(authCubit: _authCubit);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppSettings.themeMode,
        builder: (context, mode, _) {
          return ValueListenableBuilder<String>(
            valueListenable: AppSettings.lang,
            builder: (context, lang, _) {
              final isRtl = lang == 'ar';
              return MaterialApp.router(
                title: 'StudyAI',
                scaffoldMessengerKey: rootMessengerKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: mode,
                locale: AppLang.materialLocale,
                supportedLocales: AppLang.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  // Empêche l'UI de devenir trop grande si la police système
                  // de l'appareil est agrandie (clamp entre 0.85 et 1.05).
                  final mq = MediaQuery.of(context);
                  final scale = mq.textScaler.scale(1.0).clamp(0.85, 1.05);
                  return MediaQuery(
                    data: mq.copyWith(textScaler: TextScaler.linear(scale)),
                    child: Directionality(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: KeyedSubtree(
                        key: ValueKey('locale-$lang'),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
                routerConfig: _router,
              );
            },
          );
        },
      ),
    );
  }
}
