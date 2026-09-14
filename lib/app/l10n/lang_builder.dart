import 'package:flutter/widgets.dart';

import '../app_settings.dart';

/// Reconstruit le sous-arbre quand la langue change.
class LangBuilder extends StatelessWidget {
  const LangBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, String lang) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppSettings.lang,
      builder: (context, lang, _) => builder(context, lang),
    );
  }
}
