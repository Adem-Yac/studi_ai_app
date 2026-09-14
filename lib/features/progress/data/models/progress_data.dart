import '../../../../core/services/study_stats.dart';

/// Niveau de maîtrise d'une matière.
class SubjectMastery {
  const SubjectMastery({
    required this.name,
    required this.level,
    required this.percent,
  });

  final String name;
  final String level; // Expert / Avancé / Intermédiaire / À consolider
  final int percent; // 0..100

  /// Libellé de niveau déduit du pourcentage réel.
  static String levelForPercent(int percent) {
    if (percent >= 90) return 'Expert';
    if (percent >= 80) return 'Avancé';
    if (percent >= 70) return 'Intermédiaire';
    return 'À consolider';
  }
}

/// Données de progression / statistiques de l'étudiant.
class ProgressData {
  const ProgressData({
    required this.studyHoursLabel,
    required this.quizzesDone,
    required this.avgScore,
    required this.streakDays,
    required this.weeklyActivity,
    required this.subjects,
    this.badgesUnlocked = 0,
    this.badgesTotal = 16,
  });

  final String studyHoursLabel; // ex "14h 30m"
  final int quizzesDone;
  final int avgScore; // %
  final int streakDays;
  final List<double> weeklyActivity; // 7 valeurs 0..1 (Lun..Dim)
  final List<SubjectMastery> subjects;
  final int badgesUnlocked;
  final int badgesTotal;

  factory ProgressData.demo() => const ProgressData(
        studyHoursLabel: '14h 30m',
        quizzesDone: 28,
        avgScore: 84,
        streakDays: 5,
        weeklyActivity: [0.45, 0.6, 0.5, 1.0, 0.3, 0.25, 0.15],
        badgesUnlocked: 8,
        subjects: [
          SubjectMastery(name: 'Flutter & Dart', level: 'Expert', percent: 92),
          SubjectMastery(
              name: 'Architecture & BLoC', level: 'Intermédiaire', percent: 78),
          SubjectMastery(
              name: 'Bases de données & Firebase', level: 'Avancé', percent: 85),
          SubjectMastery(
              name: 'Laravel & APIs REST', level: 'À consolider', percent: 64),
        ],
      );

  factory ProgressData.fromMap(Map<String, dynamic> m) => ProgressData(
        studyHoursLabel: (m['studyHoursLabel'] ?? '0h').toString(),
        quizzesDone: (m['quizzesDone'] as num?)?.toInt() ?? 0,
        avgScore: (m['avgScore'] as num?)?.toInt() ?? 0,
        streakDays: (m['streakDays'] as num?)?.toInt() ?? 0,
        weeklyActivity: (m['weeklyActivity'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble())
            .toList(),
        subjects: (m['subjects'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .map((s) => SubjectMastery(
                  name: (s['name'] ?? '').toString(),
                  level: (s['level'] ?? '').toString(),
                  percent: (s['percent'] as num?)?.toInt() ?? 0,
                ))
            .toList(),
      );

  /// Construit la progression à partir de statistiques réelles.
  factory ProgressData.fromStats(StudyStats stats) {
    final subjects = stats.subjectScores.entries
        .map((e) => SubjectMastery(
              name: e.key,
              level: SubjectMastery.levelForPercent(e.value),
              percent: e.value,
            ))
        .toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));

    return ProgressData(
      studyHoursLabel: stats.studyHoursLabel,
      quizzesDone: stats.attempts,
      avgScore: stats.avgScore,
      streakDays: stats.streakDays,
      weeklyActivity: stats.weeklyActivity,
      subjects: subjects,
      badgesUnlocked: stats.badgesUnlocked,
    );
  }
}
