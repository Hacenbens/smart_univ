import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_univ/core/constants/app_constants.dart';
import 'package:smart_univ/core/cubit/connectivity_cubit.dart';
import 'package:smart_univ/core/services/connectivity_service.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/data/local/app_database.dart';
import 'package:smart_univ/data/local/daos/announcements_dao.dart';
import 'package:smart_univ/data/local/daos/events_dao.dart';
import 'package:smart_univ/core/network/dio_client.dart';
import 'package:smart_univ/core/network/logging_interceptor.dart';
import 'package:smart_univ/core/network/token_provider.dart';
import 'package:smart_univ/data/datasources/announcement_local_datasource.dart';
import 'package:smart_univ/data/datasources/announcement_local_datasource_impl.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource_impl.dart';
import 'package:smart_univ/data/datasources/auth0_token_provider.dart';
import 'package:smart_univ/data/datasources/event_local_datasource.dart';
import 'package:smart_univ/data/datasources/event_local_datasource_impl.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource_impl.dart';
import 'package:smart_univ/data/repositories/announcement_repository_impl.dart';
import 'package:smart_univ/data/repositories/event_repository_impl.dart';
import 'package:smart_univ/data/repositories/stub_auth_repository.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';
import 'package:smart_univ/core/usecases/app_initialization_use_case.dart';
import 'package:smart_univ/domain/usecases/get_announcements_use_case.dart';
import 'package:smart_univ/domain/usecases/get_events_use_case.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({void Function()? onAuthExpired}) async {
  // ── Logging ──────────────────────────────────────────────────────────────────
  await LoggingInterceptor.init();

  // ── Services ─────────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => SettingsService(prefs));
  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => ConnectivityCubit(sl<ConnectivityService>()));

  // ── Local Database ───────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => sl<AppDatabase>().announcementsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().eventsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().timetableDao);

  // ── Auth0 ────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Auth0>(
    () => Auth0(AppConstants.auth0Domain, AppConstants.auth0ClientId),
  );

  // ── Network ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenProvider>(
    () => Auth0TokenProvider(sl<Auth0>().credentialsManager),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenProvider: sl<TokenProvider>(),
      onAuthExpired: onAuthExpired ?? () {},
    ),
  );

  // ── Local Data Sources ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AnnouncementLocalDataSource>(
    () => AnnouncementLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(sl()),
  );

  // ── Remote Data Sources ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl<DioClient>()),
  );

  // ── Repositories ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(
      sl<AnnouncementRemoteDataSource>(),
      sl<AnnouncementLocalDataSource>(),
      sl<ConnectivityService>(),
    ),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      sl<EventRemoteDataSource>(),
      sl<EventLocalDataSource>(),
      sl<ConnectivityService>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => StubAuthRepository(),
  );

  // ── Use Cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => AppInitializationUseCase(sl<AnnouncementsDao>(), sl<EventsDao>()),
  );
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl<AnnouncementRepository>()));
  sl.registerLazySingleton(() => GetEventsUseCase(sl<EventRepository>()));

  // ── BLoCs ───────────────────────────────────────────────────────────────────
  sl.registerFactory(() => AnnouncementsBloc(sl<GetAnnouncementsUseCase>()));
  sl.registerFactory(() => EventsBloc(sl<GetEventsUseCase>()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => SettingsBloc(sl<SettingsService>()));
}
