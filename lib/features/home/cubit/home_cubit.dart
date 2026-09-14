import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/home_repository.dart';

sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);
  final HomeData data;
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeLoading());

  final HomeRepository _repository;

  Future<void> load() async {
    if (state is! HomeLoaded) emit(const HomeLoading());
    try {
      final data = await _repository.load();
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
