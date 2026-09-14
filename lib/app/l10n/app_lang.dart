import 'package:flutter/widgets.dart';

import '../app_settings.dart';

/// Langues supportées par StudyAI (français par défaut).
abstract final class AppLang {
  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
  ];

  static Locale get materialLocale => Locale(AppSettings.lang.value);

  static bool get isRtl => AppSettings.lang.value == 'ar';
}
