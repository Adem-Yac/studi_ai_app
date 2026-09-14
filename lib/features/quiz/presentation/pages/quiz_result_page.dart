import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../data/models/quiz.dart';

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({super.key, required this.attempt});
  final QuizAttempt attempt;

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool _showMistakes = false;

  QuizAttempt get a => widget.attempt;

  Color get _scoreColor {
    if (a.percent >= 80) return AppColors.success;
    if (a.percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const StudyAIAppBarTitle(),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenMargin, 8, AppLayout.screenMargin, 32),
              children: [
                const Center(child: StudyAILogo(size: 56, radius: 16)),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      a.percent >= 80
                          ? '🏆'
                          : (a.percent >= 50 ? S.wellDone : S.keepGoing),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: a.ratio,
                            strokeWidth: 14,
                            backgroundColor: AppColors.subtleOf(context),
                            valueColor: AlwaysStoppedAnimation(_scoreColor),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${a.percent}%',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: _scoreColor,
                                )),
                            Text('${a.correct} / ${a.total}',
                                style: TextStyle(
                                  color: AppColors.mutedOf(context),
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(S.yourScore,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOf(context),
                      )),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        icon: Icons.check_circle_rounded,
                        value: '${a.correct}',
                        label: S.correctAnswers,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        icon: Icons.cancel_rounded,
                        value: '${a.wrong}',
                        label: S.wrongAnswers,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (a.wrong > 0)
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showMistakes = !_showMistakes),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(color: AppColors.borderOf(context)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: Icon(_showMistakes
                        ? Icons.visibility_off_rounded
                        : Icons.search_rounded),
                    label: Text(_showMistakes ? S.hide : S.seeMistakes),
                  ),
                if (_showMistakes) ...[
                  const SizedBox(height: 12),
                  for (final i in a.wrongIndexes) _MistakeCard(attempt: a, index: i),
                ],
                const SizedBox(height: 16),
                GradientButton(
                  label: S.retryQuiz,
                  icon: Icons.refresh_rounded,
                  onPressed: () =>
                      context.pushReplacement('/quiz/play', extra: a.quiz),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(S.backHome,
                      style: TextStyle(
                        color: AppColors.mutedOf(context),
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textOf(context),
              )),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.softOf(context))),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.attempt, required this.index});
  final QuizAttempt attempt;
  final int index;

  @override
  Widget build(BuildContext context) {
    final q = attempt.quiz.questions[index];
    final chosen = attempt.answers.length > index ? attempt.answers[index] : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Q${index + 1}. ${q.question}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOf(context),
                )),
            const SizedBox(height: 10),
            if (chosen != null && chosen < q.options.length)
              _AnswerRow(
                icon: Icons.close_rounded,
                color: AppColors.error,
                label: S.yourAnswer(q.options[chosen]),
              ),
            _AnswerRow(
              icon: Icons.check_rounded,
              color: AppColors.success,
              label: S.correctAnswer(q.options[q.correctIndex]),
            ),
            if (q.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('💡 ${q.explanation}',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.mutedOf(context),
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(color: AppColors.textOf(context))),
          ),
        ],
      ),
    );
  }
}
