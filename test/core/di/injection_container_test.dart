import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/services/camera_service.dart';
import 'package:smart_univ/core/services/permission_service.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';
import 'package:smart_univ/domain/repositories/auth_repository.dart';
import 'package:smart_univ/domain/repositories/event_repository.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    await GetIt.instance.reset();
    await initDependencies();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('initDependencies', () {
    group('services are registered as lazy singletons', () {
      test('PermissionService resolves', () {
        expect(sl<PermissionService>(), isA<PermissionService>());
      });

      test('PermissionService returns same instance each call', () {
        expect(sl<PermissionService>(), same(sl<PermissionService>()));
      });

      test('CameraService resolves', () {
        expect(sl<CameraService>(), isA<CameraService>());
      });

      test('CameraService returns same instance each call', () {
        expect(sl<CameraService>(), same(sl<CameraService>()));
      });
    });

    group('repositories are registered as lazy singletons', () {
      test('AnnouncementRepository resolves', () {
        expect(sl<AnnouncementRepository>(), isA<AnnouncementRepository>());
      });

      test('EventRepository resolves', () {
        expect(sl<EventRepository>(), isA<EventRepository>());
      });

      test('AuthRepository resolves', () {
        expect(sl<AuthRepository>(), isA<AuthRepository>());
      });

      test('AnnouncementRepository returns same instance each call', () {
        expect(sl<AnnouncementRepository>(), same(sl<AnnouncementRepository>()));
      });
    });

    group('blocs are registered as factories', () {
      test('AnnouncementsBloc resolves', () {
        final bloc = sl<AnnouncementsBloc>();
        expect(bloc, isA<AnnouncementsBloc>());
        bloc.close();
      });

      test('EventsBloc resolves', () {
        final bloc = sl<EventsBloc>();
        expect(bloc, isA<EventsBloc>());
        bloc.close();
      });

      test('AuthBloc resolves', () {
        final bloc = sl<AuthBloc>();
        expect(bloc, isA<AuthBloc>());
        bloc.close();
      });

      test('SettingsBloc resolves', () {
        final bloc = sl<SettingsBloc>();
        expect(bloc, isA<SettingsBloc>());
        bloc.close();
      });

      test('AnnouncementsBloc factory returns new instance each call', () {
        final a = sl<AnnouncementsBloc>();
        final b = sl<AnnouncementsBloc>();
        expect(a, isNot(same(b)));
        a.close();
        b.close();
      });
    });
  });
}
