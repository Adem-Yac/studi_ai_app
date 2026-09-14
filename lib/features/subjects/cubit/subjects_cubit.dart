import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/study_subject.dart';
import '../data/repositories/subjects_repository.dart';

class SubjectsState {
  const SubjectsState({
    this.items = const [],
    this.loading = true,
    this.error,
  });

  final List<StudySubject> items;
  final bool loading;
  final String? error;

  SubjectsState copyWith({
    List<StudySubject>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) =>
      SubjectsState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit(this._repo) : super(const SubjectsState());

  final SubjectsRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _repo.list();
      emit(SubjectsState(items: items, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: '$e'));
    }
  }

  Future<void> add(String name, {int colorIndex = 0}) async {
    try {
      final created = await _repo.create(name: name, colorIndex: colorIndex);
      emit(state.copyWith(items: [...state.items, created]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        )));
    } catch (e) {
      emit(state.copyWith(error: '$e'));
    }
  }

  Future<void> save(StudySubject subject) async {
    await _repo.update(subject);
    emit(state.copyWith(
      items: [
        for (final s in state.items)
          if (s.id == subject.id) subject else s,
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    ));
  }

  Future<void> rename(StudySubject subject, String name) async {
    await save(StudySubject(
      id: subject.id,
      name: name.trim(),
      colorIndex: subject.colorIndex,
    ));
  }

  Future<void> remove(StudySubject subject) async {
    await _repo.delete(subject.id);
    emit(state.copyWith(
      items: state.items.where((s) => s.id != subject.id).toList(),
    ));
  }
}
