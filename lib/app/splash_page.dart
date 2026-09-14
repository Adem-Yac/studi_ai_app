import 'package:flutter/material.dart';

import '../core/widgets/studyai_logo.dart';
import 'l10n/app_strings.dart';
import 'theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.06).animate(
                CurvedAnimation(parent: _c, curve: Curves.easeInOut),
              ),
              child: const StudyAILogo(size: 84),
            ),
            const SizedBox(height: 22),
            const StudyAIWordmark(fontSize: 28),
            const SizedBox(height: 10),
            Text(
              S.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedOf(context), fontSize: 13),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: AppColors.subtleOf(context),
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
