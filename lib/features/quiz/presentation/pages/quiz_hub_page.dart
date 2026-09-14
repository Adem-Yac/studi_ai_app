import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizHubPage extends StatefulWidget {
  const QuizHubPage({super.key});

  @override
  State<QuizHubPage> createState() => _QuizHubPageState();
}

class _QuizHubPageState extends State<QuizHubPage> {
  final _topic = TextEditingController();
  List<Quiz> _quizzes = const [];
  bool _generating = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await getIt<QuizRepository>().listRecent();
    if (!mounted) return;
    setState(() {
      _quizzes = list;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _topic.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.enterQuizTopic)),
      );
      return;
    }
    setState(() => _generating = true);
    try {
      final quiz = await getIt<QuizRepository>().generate(topic: topic, count: 5);
      if (!mounted) return;
      setState(() {
        _generating = false;
        _quizzes = [quiz, ..._quizzes.where((q) => q.id != quiz.id)];
      });
      context.push('/quiz/play', extra: quiz);
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.generationFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldOf(context),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                12,
                AppLayout.screenMargin,
                AppLayout.bottomNavClearance,
              ),
              children: [
                const StudyAIBrandBar(),
                const SizedBox(height: 4),
                Text(S.quizSubtitle,
                    style: TextStyle(color: AppColors.mutedOf(context))),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(S.generateCustomQuiz,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textOf(context),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _topic,
                        onSubmitted: (_) => _generate(),
                        decoration: InputDecoration(
                          hintText: S.quizTopicHint,
                          filled: true,
                          fillColor: AppColors.altSurfaceOf(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: S.generateWithGemini,
                        icon: Icons.bolt_rounded,
                        loading: _generating,
                        onPressed: _generate,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/flashcards'),
                        icon: const Icon(Icons.style_rounded),
                        label: Text(S.openFlashcards),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: S.yourQuizzes),
                const SizedBox(height: 8),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_quizzes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      S.emptyQuizHint,
                      style: TextStyle(color: AppColors.mutedOf(context)),
                    ),
                  )
                else
                  for (final quiz in _quizzes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HubQuizCard(quiz: quiz),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HubQuizCard extends StatelessWidget {
  const _HubQuizCard({required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/quiz/play', extra: quiz),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.chipOf(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.quiz_rounded, color: AppColors.primaryOf(context)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOf(context),
                    )),
                const SizedBox(height: 4),
                Text('${quiz.length} questions · ${quiz.durationMin} min · '
                    '${quiz.difficulty}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.softOf(context),
                    )),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded,
              color: AppColors.primaryOf(context), size: 34),
        ],
      ),
    );
  }
}
