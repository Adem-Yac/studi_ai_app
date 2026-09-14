import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/navigation/study_opener.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../../quiz/data/models/quiz.dart';
import '../../cubit/home_cubit.dart';
import '../../data/models/course.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.onOpenChat,
    required this.onOpenTab,
  });

  final void Function(String prompt) onOpenChat;
  final void Function(int index) onOpenTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..load(),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().load(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.screenMargin,
                      12,
                      AppLayout.screenMargin,
                      AppLayout.bottomNavClearance,
                    ),
                    children: [
                      const StudyAIBrandBar(),
                      const SizedBox(height: 8),
                      _SearchBar(),
                      const SizedBox(height: 16),
                      _AskCard(onOpenChat: onOpenChat),
                      const SizedBox(height: 24),
                      _CoursesSection(state: state),
                      const SizedBox(height: 24),
                      _ProgressSection(
                        state: state,
                        onSeeMore: () => context.push('/progress'),
                      ),
                      const SizedBox(height: 24),
                      _QuizSection(
                        state: state,
                        onOpenQuizTab: () => onOpenTab(3),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardOf(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/search'),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.softOf(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.searchHint,
                  style: TextStyle(color: AppColors.softOf(context)),
                ),
              ),
              Icon(Icons.tune_rounded,
                  color: AppColors.softOf(context), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskCard extends StatelessWidget {
  const _AskCard({required this.onOpenChat});
  final void Function(String prompt) onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(S.askStudyAiBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        )),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF34D399),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            S.askStudyAI,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.askPrompt,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onOpenChat(''),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨  ${S.startConversation}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesSection extends StatefulWidget {
  const _CoursesSection({required this.state});
  final HomeState state;

  @override
  State<_CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<_CoursesSection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final courses =
        widget.state is HomeLoaded ? (widget.state as HomeLoaded).data.courses : <Course>[];
    if (_selected >= courses.length) _selected = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: S.myCourses,
          actionLabel: '${S.seeAll} (${courses.length})',
          onAction: () => context.push('/courses'),
        ),
        const SizedBox(height: 10),
        if (courses.isEmpty)
          Text(
            S.noCoursesYet,
            style: TextStyle(color: AppColors.mutedOf(context), fontSize: 13),
          )
        else ...[
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final active = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.cardOf(context),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : AppColors.borderOf(context),
                      ),
                    ),
                    child: Text(
                      courses[i].subject.isNotEmpty
                          ? courses[i].subject
                          : courses[i].title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            active ? Colors.white : AppColors.textOf(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ActiveCourseCard(course: courses[_selected]),
        ],
      ],
    );
  }
}

class _ActiveCourseCard extends StatelessWidget {
  const _ActiveCourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => StudyOpener.openCourse(context, course),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: course.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book_rounded, color: course.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(S.active,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Text(course.updatedLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.softOf(context),
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                Text(course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOf(context),
                    )),
                const SizedBox(height: 2),
                Text(course.chapter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedOf(context),
                    )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.softOf(context)),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.state, required this.onSeeMore});
  final HomeState state;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    final data = state is HomeLoaded ? (state as HomeLoaded).data : null;
    final percent = data?.weekProgress ?? 0;
    final validated = data?.validatedCount ?? 0;
    final (headline, subline) = switch (percent) {
      0 => (S.progressStartTitle, S.progressStartSub),
      >= 0.8 => (S.progressHighTitle, S.progressHighSub),
      >= 0.5 => (S.progressMidTitle, S.progressMidSub),
      _ => (S.progressLowTitle, S.progressLowSub),
    };
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.weekProgress,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(context),
                  )),
              const Spacer(),
              Text('${(percent * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 7,
                        backgroundColor: AppColors.subtleOf(context),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Text('${(percent * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textOf(context),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOf(context),
                        )),
                    const SizedBox(height: 4),
                    Text(subline,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedOf(context),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                icon: Icons.schedule_rounded,
                value: data?.studyHoursLabel ?? '0h',
                label: S.ofStudy,
              ),
              _MiniStat(
                icon: Icons.check_circle_outline_rounded,
                value: '$validated',
                label: S.validated,
                color: AppColors.success,
              ),
              _MiniStat(
                icon: Icons.local_fire_department_rounded,
                value: '${data?.streakDays ?? 0}j',
                label: S.streakLabel,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSeeMore,
              child: Text(S.seeDetails,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              )),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppColors.softOf(context))),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({required this.state, required this.onOpenQuizTab});
  final HomeState state;
  final VoidCallback onOpenQuizTab;

  @override
  Widget build(BuildContext context) {
    final quizzes =
        state is HomeLoaded ? (state as HomeLoaded).data.recommendedQuizzes : <Quiz>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: S.recommendedQuiz,
          actionLabel: S.discover,
          onAction: onOpenQuizTab,
        ),
        const SizedBox(height: 10),
        if (quizzes.isEmpty)
          Text(
            S.noQuizzesYet,
            style: TextStyle(color: AppColors.mutedOf(context), fontSize: 13),
          )
        else
          for (final quiz in quizzes) ...[
            _QuizCard(quiz: quiz),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.chipOf(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(S.difficulty(quiz.difficulty),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOf(context),
                    )),
              ),
              const Spacer(),
              Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.softOf(context)),
              const SizedBox(width: 4),
              Text('${quiz.durationMin} min',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.softOf(context),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(quiz.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textOf(context),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.list_alt_rounded,
                  size: 16, color: AppColors.softOf(context)),
              const SizedBox(width: 6),
              Text('${quiz.length} ${S.questionsCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedOf(context),
                  )),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/quiz/play', extra: quiz),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(110, 40),
                  backgroundColor: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.startQuiz),
                    const SizedBox(width: 4),
                    const Icon(Icons.play_arrow_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
