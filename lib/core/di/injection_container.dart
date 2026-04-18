import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_univ/core/constants/app_constants.dart';
import 'package:smart_univ/core/network/dio_client.dart';
import 'package:smart_univ/core/network/token_provider.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource.dart';
import 'package:smart_univ/data/datasources/announcement_remote_datasource_impl.dart';
import 'package:smart_univ/data/datasources/auth0_token_provider.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource.dart';
import 'package:smart_univ/data/datasources/event_remote_datasource_impl.dart';
import 'package:smart_univ/data/repositories/stub_announcement_repository.dart';
import 'package:smart_univ/data/repositories/stub_auth_repository.dart';
import 'package:smart_univ/data/repositories/stub_event_repository.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({void Function()? onAuthExpired}) async {
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

  // ── Remote Data Sources ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl<DioClient>()),
  );

  // ── Repositories ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AnnouncementRepository>(
    () => StubAnnouncementRepository(),
  );
  sl.registerLazySingleton<EventRepository>(
    () => StubEventRepository(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => StubAuthRepository(),
  );

  // ── BLoCs ───────────────────────────────────────────────────────────────────
  sl.registerFactory(() => AnnouncementsBloc(sl()));
  sl.registerFactory(() => EventsBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => SettingsBloc());
}
