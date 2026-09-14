import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/quiz.dart';
import '../data/repositories/quiz_repository.dart';

class QuizSessionState {
  const QuizSessionState({
    required this.quiz,
    required this.currentIndex,
    required this.answers,
    this.finished = false,
  });

  final Quiz quiz;
  final int currentIndex;
  final List<int?> answers;
  final bool finished;

  QuizQuestion get current => quiz.questions[currentIndex];
  int? get selected => answers[currentIndex];
  bool get isLast => currentIndex == quiz.questions.length - 1;
  double get progress =>
      quiz.questions.isEmpty ? 0 : (currentIndex + 1) / quiz.questions.length;

  QuizAttempt get attempt => QuizAttempt(quiz: quiz, answers: answers);

  QuizSessionState copyWith({
    int? currentIndex,
    List<int?>? answers,
    bool? finished,
  }) =>
      QuizSessionState(
        quiz: quiz,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        finished: finished ?? this.finished,
      );
}

class QuizCubit extends Cubit<QuizSessionState> {
  QuizCubit(Quiz quiz, this._repository)
      : super(QuizSessionState(
          quiz: quiz,
          currentIndex: 0,
          answers: List<int?>.filled(quiz.questions.length, null),
        ));

  final QuizRepository _repository;

  void select(int optionIndex) {
    final answers = List<int?>.from(state.answers);
    answers[state.currentIndex] = optionIndex;
    emit(state.copyWith(answers: answers));
  }

  void next() {
    if (state.isLast) {
      finish();
    } else {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previous() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void skip() => next();

  void finish() {
    emit(state.copyWith(finished: true));
    _repository.saveAttempt(state.attempt);
  }

  void restart() => emit(state.copyWith(
        currentIndex: 0,
        answers: List<int?>.filled(state.quiz.questions.length, null),
        finished: false,
      ));
}
