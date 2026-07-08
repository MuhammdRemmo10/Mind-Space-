import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/articles/data/repositories/articles_repository_impl.dart';
import '../../features/articles/domain/repositories/articles_repository.dart';
import '../../features/articles/presentation/cubit/articles_cubit.dart';
import '../../features/content_library/presentation/cubit/content_library_cubit.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/files/data/repositories/files_repository_impl.dart';
import '../../features/files/domain/repositories/files_repository.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/settings/presentation/cubit/locale_cubit.dart';
import '../../features/settings/presentation/cubit/theme_cubit.dart';
import '../../features/spaces/data/repositories/spaces_repository_impl.dart';
import '../../features/spaces/domain/repositories/spaces_repository.dart';
import '../../features/spaces/presentation/cubit/spaces_cubit.dart';
import '../../features/tags/data/repositories/tags_repository_impl.dart';
import '../../features/tags/domain/repositories/tags_repository.dart';
import '../../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../../features/tasks/data/repositories/task_lists_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_lists_repository.dart';
import '../../features/tasks/domain/repositories/tasks_repository.dart';
import '../../features/tasks/presentation/cubit/tasks_cubit.dart';
import '../../features/notes/presentation/cubit/notes_cubit.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();

  sl
    ..registerLazySingleton<SharedPreferences>(() => preferences)
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(sl()))
    ..registerLazySingleton<Dio>(() => DioClient.create(sl()))
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SpacesRepository>(() => SpacesRepositoryImpl(sl()))
    ..registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(sl()))
    ..registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(sl()))
    ..registerLazySingleton<TaskListsRepository>(
      () => TaskListsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<ArticlesRepository>(
      () => ArticlesRepositoryImpl(sl()),
    )
    ..registerLazySingleton<TagsRepository>(() => TagsRepositoryImpl(sl()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton<FilesRepository>(() => FilesRepositoryImpl(sl()))
    ..registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetDashboardSummary(sl()))
    ..registerFactory(() => DashboardCubit(sl()))
    ..registerFactory(() => AuthCubit(sl()))
    ..registerFactory(() => SpacesCubit(sl()))
    ..registerFactory(() => NotesCubit(sl(), sl()))
    ..registerFactory(() => TasksCubit(sl(), sl()))
    ..registerFactory(() => ArticlesCubit(sl(), sl()))
    ..registerFactory(() => ContentLibraryCubit(sl(), sl(), sl()))
    ..registerFactory(() => ProfileCubit(sl()))
    ..registerFactory(() => LocaleCubit(sl()))
    ..registerFactory(() => ThemeCubit(sl()));
}
