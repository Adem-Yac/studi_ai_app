import 'package:flutter/material.dart';

import '../core/constants/app_layout.dart';
import '../core/widgets/gradient_button.dart';
import '../core/widgets/studyai_logo.dart';
import 'l10n/app_strings.dart';
import 'theme/app_colors.dart';

class _Slide {
  const _Slide(this.icon, this.badge, this.title, this.body, this.chips);
  final IconData icon;
  final String badge;
  final String title;
  final String body;
  final List<String> chips;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  List<_Slide> get _slides => [
        _Slide(
          Icons.menu_book_rounded,
          S.onboardingBadge1,
          S.onboardingTitle1,
          S.onboardingBody1,
          [S.summarize, S.flashcards],
        ),
        _Slide(
          Icons.chat_bubble_rounded,
          S.onboardingBadge2,
          S.onboardingTitle2,
          S.onboardingBody2,
          [S.navChat, S.importPdf],
        ),
        _Slide(
          Icons.quiz_rounded,
          S.onboardingBadge3,
          S.onboardingTitle3,
          S.onboardingBody3,
          [S.quiz, S.myProgress],
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      widget.onFinished();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenMargin),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          const StudyAILogo(size: 26, radius: 8),
                          const SizedBox(width: 8),
                          Text('STUDYAI 2.0',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1,
                                color: AppColors.primaryOf(context),
                              )),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.onFinished,
                        child: Text(S.skip,
                            style: TextStyle(
                                color: AppColors.mutedOf(context),
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.primary
                                : AppColors.borderOf(context),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    label: S.continueLabel,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.secondary.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: const StudyAILogo(size: 84, radius: 24),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipOf(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(slide.badge,
                style: TextStyle(
                  color: AppColors.primaryOf(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                )),
          ),
          const SizedBox(height: 14),
          Text(slide.title,
              style: TextStyle(
                fontSize: 30,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              )),
          const SizedBox(height: 12),
          Text(slide.body,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.mutedOf(context),
              )),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in slide.chips)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.altSurfaceOf(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Text(chip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOf(context),
                      )),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
