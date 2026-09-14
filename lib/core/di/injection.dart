import 'package:get_it/get_it.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/user_repository.dart';
import '../../features/chat/cubit/chat_cubit.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/documents/cubit/documents_cubit.dart';
import '../../features/documents/data/repositories/documents_repository.dart';
import '../../features/flashcards/data/repositories/flashcards_repository.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/progress/cubit/progress_cubit.dart';
import '../../features/progress/data/repositories/progress_repository.dart';
import '../../features/quiz/data/repositories/quiz_repository.dart';
import '../../features/search/data/search_repository.dart';
import '../../features/subjects/cubit/subjects_cubit.dart';
import '../../features/subjects/data/repositories/subjects_repository.dart';
import '../services/gemini_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<GeminiService>()) return;

  // ——— Services ———
  getIt.registerLazySingleton<GeminiService>(GeminiService.new);

  // ——— Repositories ———
  getIt.registerLazySingleton<UserRepository>(UserRepository.new);
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(userRepository: getIt()),
  );
  getIt.registerLazySingleton<HomeRepository>(HomeRepository.new);
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt()));
  getIt.registerLazySingleton<DocumentsRepository>(
    () => DocumentsRepository(getIt()),
  );
  getIt.registerLazySingleton<QuizRepository>(() => QuizRepository(getIt()));
  getIt.registerLazySingleton<ProgressRepository>(ProgressRepository.new);
  getIt.registerLazySingleton<SubjectsRepository>(SubjectsRepository.new);
  getIt.registerLazySingleton<FlashcardsRepository>(
    () => FlashcardsRepository(getIt()),
  );
  getIt.registerLazySingleton<SearchRepository>(SearchRepository.new);

  // ——— Cubits ———
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt()));
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt()));
  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt())..loadHistory());
  getIt.registerFactory<DocumentsCubit>(() => DocumentsCubit(getIt()));
  getIt.registerFactory<ProgressCubit>(() => ProgressCubit(getIt()));
  getIt.registerFactory<SubjectsCubit>(() => SubjectsCubit(getIt()));
}
