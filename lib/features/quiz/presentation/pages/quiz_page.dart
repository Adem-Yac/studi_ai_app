import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/quiz_cubit.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(quiz, getIt<QuizRepository>()),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatefulWidget {
  const _QuizView();

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizCubit, QuizSessionState>(
      listenWhen: (a, b) => !a.finished && b.finished,
      listener: (context, state) {
        _timer?.cancel();
        context.pushReplacement('/quiz/result', extra: state.attempt);
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldOf(context),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          title: const StudyAIAppBarTitle(),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.chipOf(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 15, color: AppColors.primaryOf(context)),
                    const SizedBox(width: 5),
                    Text(_timeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOf(context),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              child: BlocBuilder<QuizCubit, QuizSessionState>(
                builder: (context, state) {
                  final cubit = context.read<QuizCubit>();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppLayout.screenMargin, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${S.question} ${state.currentIndex + 1} '
                                  '/ ${state.quiz.length}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mutedOf(context),
                                  ),
                                ),
                                const Spacer(),
                                Text('${(state.progress * 100).round()}%',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: state.progress,
                                minHeight: 8,
                                backgroundColor: AppColors.subtleOf(context),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.screenMargin, vertical: 12),
                          children: [
                            Text(
                              state.current.question,
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.35,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textOf(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            for (var i = 0; i < state.current.options.length; i++)
                              _OptionTile(
                                letter: String.fromCharCode(65 + i),
                                text: state.current.options[i],
                                selected: state.selected == i,
                                onTap: () => cubit.select(i),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppLayout.screenMargin, 8,
                            AppLayout.screenMargin, 16),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: cubit.skip,
                              child: Text(S.skipQuestion,
                                  style: TextStyle(
                                    color: AppColors.mutedOf(context),
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: state.selected == null ? null : cubit.next,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(150, 52),
                                backgroundColor: AppColors.primary,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(state.isLast ? S.finish : S.next),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderOf(context),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.altSurfaceOf(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(letter,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color:
                        selected ? Colors.white : AppColors.mutedOf(context),
                  )),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOf(context),
                  )),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
