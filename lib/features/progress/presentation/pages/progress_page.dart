import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_layout.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/studyai_logo.dart';
import '../../cubit/progress_cubit.dart';
import '../../data/models/progress_data.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgressCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldOf(context),
        appBar: AppBar(title: const StudyAIAppBarTitle()),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                  if (state is! ProgressLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final d = state.data;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppLayout.screenMargin, 8, AppLayout.screenMargin, 32),
                    children: [
                      Text(S.progressPowered,
                          style: TextStyle(color: AppColors.mutedOf(context))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.schedule_rounded,
                              value: d.studyHoursLabel,
                              label: S.studyTime,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.fact_check_rounded,
                              value: '${d.quizzesDone}',
                              label: S.quizDone,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events_rounded,
                              value: '${d.avgScore}%',
                              label: S.avgScore,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department_rounded,
                              value: '${d.streakDays} j',
                              label: S.activeStreak,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _WeeklyChart(activity: d.weeklyActivity),
                      const SizedBox(height: 20),
                      SectionHeader(title: S.masteryBySubject),
                      const SizedBox(height: 8),
                      for (final s in d.subjects)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MasteryBar(subject: s),
                        ),
                      const SizedBox(height: 12),
                      _BadgesCard(unlocked: d.badgesUnlocked, total: d.badgesTotal),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textOf(context),
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.softOf(context))),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.activity});
  final List<double> activity;

  @override
  Widget build(BuildContext context) {
    var maxIdx = 0;
    for (var i = 1; i < activity.length; i++) {
      if (activity[i] > activity[maxIdx]) maxIdx = i;
    }
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.weeklyActivity,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              )),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < activity.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (i == maxIdx)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${(activity[i] * 4).toStringAsFixed(1)}h',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 100 * activity[i] + 8,
                          decoration: BoxDecoration(
                            gradient: i == maxIdx
                                ? AppColors.brandGradient
                                : null,
                            color: i == maxIdx
                                ? null
                                : AppColors.subtleOf(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(S.weekday(i),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.softOf(context),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  const _MasteryBar({required this.subject});
  final SubjectMastery subject;

  Color get _color {
    if (subject.percent >= 90) return AppColors.success;
    if (subject.percent >= 80) return AppColors.primary;
    if (subject.percent >= 70) return AppColors.secondary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(subject.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOf(context),
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(subject.level,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _color,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: subject.percent / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.subtleOf(context),
                    valueColor: AlwaysStoppedAnimation(_color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${subject.percent}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(context),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  const _BadgesCard({required this.unlocked, required this.total});
  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final badges = [
      ('🥇', S.badgeQuizGenius, S.badgeGold),
      ('🎓', S.badgeRegular, S.badgeSilver),
      ('🧭', S.badgeExplorer, S.badgeBronze),
    ];
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.badgesRewards,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(context),
                  )),
              const Spacer(),
              Text('$unlocked / $total',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final b in badges)
                Expanded(
                  child: Column(
                    children: [
                      Text(b.$1, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(b.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOf(context),
                          )),
                      Text(b.$3,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.softOf(context),
                          )),
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
