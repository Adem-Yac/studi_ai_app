import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Logo StudyAI : image de marque (chapeau de diplômé sur dégradé indigo→violet).
class StudyAILogo extends StatelessWidget {
  const StudyAILogo({super.key, this.size = 56, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.30;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: size * 0.30,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(gradient: AppColors.brandGradient),
            child: Icon(Icons.school_rounded,
                color: Colors.white, size: size * 0.52),
          ),
        ),
      ),
    );
  }
}

/// Bandeau commun : logo + nom de l'app (toutes les pages principales).
class StudyAIBrandBar extends StatelessWidget {
  const StudyAIBrandBar({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Row(
        children: [
          const StudyAILogo(size: 36, radius: 10),
          const SizedBox(width: 10),
          const StudyAIWordmark(fontSize: 20),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
class StudyAIWordmark extends StatelessWidget {
  const StudyAIWordmark({super.key, this.fontSize = 30});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.textOf(context),
        ),
        children: const [
          TextSpan(text: 'Study'),
          TextSpan(text: 'AI', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}

/// Titre d'AppBar : logo + nom de l'app.
class StudyAIAppBarTitle extends StatelessWidget {
  const StudyAIAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        StudyAILogo(size: 28, radius: 8),
        SizedBox(width: 8),
        StudyAIWordmark(fontSize: 18),
      ],
    );
  }
}
