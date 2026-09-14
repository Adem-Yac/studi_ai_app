import '../../../../core/services/gemini_service.dart';

/// Une question de QCM.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromGenerated(GeneratedQuestion g) => QuizQuestion(
        question: g.question,
        options: g.options,
        correctIndex: g.correctIndex,
        explanation: g.explanation,
      );

  factory QuizQuestion.fromMap(Map<String, dynamic> m) => QuizQuestion(
        question: (m['question'] ?? '').toString(),
        options:
            (m['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        correctIndex: (m['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: (m['explanation'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

/// Un quiz complet.
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.questions,
    this.durationMin = 15,
    this.difficulty = 'Moyenne',
  });

  final String id;
  final String title;
  final String subject;
  final List<QuizQuestion> questions;
  final int durationMin;
  final String difficulty;

  int get length => questions.length;

  factory Quiz.fromMap(String id, Map<String, dynamic> m) => Quiz(
        id: id,
        title: (m['title'] ?? '').toString(),
        subject: (m['subject'] ?? '').toString(),
        durationMin: (m['durationMin'] as num?)?.toInt() ?? 15,
        difficulty: (m['difficulty'] ?? 'Moyenne').toString(),
        questions: (m['questions'] as List<dynamic>? ?? [])
            .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'durationMin': durationMin,
        'difficulty': difficulty,
        'questions': questions.map((q) => q.toMap()).toList(),
      };

  static List<Quiz> demoRecommended() => [
        Quiz(
          id: 'q1',
          title: 'Flutter State Management (Provider & Riverpod)',
          subject: 'Flutter',
          durationMin: 15,
          difficulty: 'Moyenne',
          questions: _demoQuestions,
        ),
        Quiz(
          id: 'q2',
          title: 'Laravel Eloquent ORM & Migrations',
          subject: 'Laravel',
          durationMin: 20,
          difficulty: 'Difficile',
          questions: _demoQuestions,
        ),
      ];

  static const List<QuizQuestion> _demoQuestions = [
    QuizQuestion(
      question:
          "Quelle méthode du cycle de vie d'un StatefulWidget est appelée une "
          "seule fois lorsque le widget est inséré dans l'arbre ?",
      options: ['build()', 'initState()', 'dispose()', 'setState()'],
      correctIndex: 1,
      explanation:
          "initState() est appelée une seule fois à la création de l'état.",
    ),
    QuizQuestion(
      question: 'Quel widget permet de reconstruire uniquement une partie de '
          "l'UI selon l'état d'un Cubit ?",
      options: ['BlocProvider', 'BlocBuilder', 'BlocListener', 'RepositoryProvider'],
      correctIndex: 1,
      explanation: 'BlocBuilder reconstruit son builder à chaque nouvel état.',
    ),
    QuizQuestion(
      question: 'Que retourne un FutureBuilder pendant le chargement ?',
      options: [
        'ConnectionState.done',
        'ConnectionState.none',
        'ConnectionState.waiting',
        'ConnectionState.active',
      ],
      correctIndex: 2,
      explanation:
          'Pendant le chargement, snapshot.connectionState vaut waiting.',
    ),
  ];
}

/// Résultat d'une tentative de quiz.
class QuizAttempt {
  QuizAttempt({required this.quiz, required this.answers});

  final Quiz quiz;
  final List<int?> answers; // index choisi par question (null = non répondu)

  int get correct {
    var c = 0;
    for (var i = 0; i < quiz.questions.length; i++) {
      if (answers.length > i && answers[i] == quiz.questions[i].correctIndex) {
        c++;
      }
    }
    return c;
  }

  int get total => quiz.questions.length;
  int get wrong => total - correct;
  double get ratio => total == 0 ? 0 : correct / total;
  int get percent => (ratio * 100).round();

  List<int> get wrongIndexes => [
        for (var i = 0; i < total; i++)
          if (answers.length <= i || answers[i] != quiz.questions[i].correctIndex)
            i
      ];
}
