import 'package:get_it/get_it.dart';
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

Future<void> initDependencies() async {
  // ── Repositories ────────────────────────────────────────────────────────────
  // Registered against the abstract interface so swapping implementations in
  // Week 2 is a one-line change here, nothing else touches.
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
  // Factories — a new instance is created each time sl() is called.
  // This prevents state leaking between screen navigations.
  sl.registerFactory(() => AnnouncementsBloc(sl()));
  sl.registerFactory(() => EventsBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => SettingsBloc());
}
