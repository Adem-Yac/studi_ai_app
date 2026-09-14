import 'package:cloud_firestore/cloud_firestore.dart';

/// Statistiques d'étude calculées à partir des tentatives de quiz réelles
/// stockées dans `users/{uid}/quizzes`.
///
/// Aucune donnée fictive : un nouvel utilisateur obtient des zéros, et les
/// valeurs augmentent au fur et à mesure des quiz réellement passés.
class StudyStats {
  const StudyStats({
    required this.attempts,
    required this.validatedCount,
    required this.avgScore,
    required this.streakDays,
    required this.studyMinutes,
    required this.weeklyActivity,
    required this.subjectScores,
  });

  /// Nombre de tentatives de quiz.
  final int attempts;

  /// Tentatives réussies (score >= 50 %).
  final int validatedCount;

  /// Score moyen (0..100).
  final int avgScore;

  /// Jours consécutifs avec au moins une tentative (fini aujourd'hui/hier).
  final int streakDays;

  /// Estimation du temps d'étude (~1 min par question répondue).
  final int studyMinutes;

  /// 7 valeurs (Lun..Dim) normalisées 0..1 pour le graphe hebdo.
  final List<double> weeklyActivity;

  /// Score moyen par matière (nom -> pourcentage).
  final Map<String, int> subjectScores;

  String get studyHoursLabel {
    final h = studyMinutes ~/ 60;
    final m = studyMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static const StudyStats empty = StudyStats(
    attempts: 0,
    validatedCount: 0,
    avgScore: 0,
    streakDays: 0,
    studyMinutes: 0,
    weeklyActivity: [0, 0, 0, 0, 0, 0, 0],
    subjectScores: {},
  );

  /// Construit les stats à partir des documents de tentatives Firestore.
  /// Seuls les documents comportant un champ `score` (= tentatives) sont pris
  /// en compte, ce qui ignore d'éventuelles définitions de quiz.
  factory StudyStats.fromAttemptDocs(List<Map<String, dynamic>> raw) {
    final docs = raw.where((m) => m['score'] != null).toList();
    if (docs.isEmpty) return empty;

    var validated = 0;
    var scoreSum = 0;
    var minutes = 0;
    final days = <DateTime>{};
    final counts = List<double>.filled(7, 0);
    final subjTotals = <String, int>{};
    final subjCounts = <String, int>{};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final m in docs) {
      final score = (m['score'] as num?)?.toInt() ?? 0;
      scoreSum += score;
      if (score >= 50) validated++;

      final total = (m['total'] as num?)?.toInt() ?? 0;
      minutes += total; // ~1 min / question répondue

      final subject =
          (m['subject'] ?? m['title'] ?? 'Général').toString().trim();
      final key = subject.isEmpty ? 'Général' : subject;
      subjTotals[key] = (subjTotals[key] ?? 0) + score;
      subjCounts[key] = (subjCounts[key] ?? 0) + 1;

      final ts = m['createdAt'];
      if (ts is Timestamp) {
        final dt = ts.toDate();
        final day = DateTime(dt.year, dt.month, dt.day);
        days.add(day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) {
          counts[dt.weekday - 1] += 1; // Lun=1..Dim=7 -> 0..6
        }
      }
    }

    // Série : jours consécutifs avec activité, en partant d'aujourd'hui (ou hier).
    var streak = 0;
    var cursor = today;
    if (!days.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
    }
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final maxCount = counts.fold<double>(0, (p, c) => c > p ? c : p);
    final weekly = maxCount <= 0
        ? List<double>.filled(7, 0)
        : counts.map((c) => c / maxCount).toList();

    final subjectScores = <String, int>{};
    subjTotals.forEach((k, v) {
      subjectScores[k] = (v / subjCounts[k]!).round();
    });

    return StudyStats(
      attempts: docs.length,
      validatedCount: validated,
      avgScore: (scoreSum / docs.length).round(),
      streakDays: streak,
      studyMinutes: minutes,
      weeklyActivity: weekly,
      subjectScores: subjectScores,
    );
  }

  /// Nombre de badges débloqués selon des paliers réels atteints (sur 16).
  int get badgesUnlocked {
    var b = 0;
    if (attempts >= 1) b++;
    if (attempts >= 5) b++;
    if (attempts >= 10) b++;
    if (attempts >= 25) b++;
    if (attempts >= 50) b++;
    if (validatedCount >= 5) b++;
    if (validatedCount >= 15) b++;
    if (avgScore >= 60) b++;
    if (avgScore >= 75) b++;
    if (avgScore >= 90) b++;
    if (streakDays >= 3) b++;
    if (streakDays >= 7) b++;
    if (streakDays >= 14) b++;
    if (subjectScores.length >= 3) b++;
    if (subjectScores.length >= 5) b++;
    if (studyMinutes >= 120) b++;
    return b;
  }
}
