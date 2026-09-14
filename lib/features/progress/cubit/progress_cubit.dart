import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/progress_data.dart';
import '../data/repositories/progress_repository.dart';

sealed class ProgressState {
  const ProgressState();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  const ProgressLoaded(this.data);
  final ProgressData data;
}

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(this._repository) : super(const ProgressLoading());

  final ProgressRepository _repository;

  Future<void> load() async {
    if (state is! ProgressLoaded) emit(const ProgressLoading());
    final data = await _repository.load();
    emit(ProgressLoaded(data));
  }
}
