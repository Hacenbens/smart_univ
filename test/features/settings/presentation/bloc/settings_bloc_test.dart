import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/domain/usecases/export_timetable_use_case.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsService extends Mock implements SettingsService {}

class MockExportTimetableUseCase extends Mock
    implements ExportTimetableUseCase {}

void main() {
  late MockSettingsService mockSettings;
  late MockExportTimetableUseCase mockExport;
  late SettingsBloc bloc;

  SettingsBloc buildBloc({
    String storedTheme = 'system',
    String storedLanguage = 'en',
    bool storedNotifications = true,
  }) {
    when(() => mockSettings.getThemeMode()).thenReturn(storedTheme);
    when(() => mockSettings.getLanguage()).thenReturn(storedLanguage);
    when(() => mockSettings.getNotificationsEnabled())
        .thenReturn(storedNotifications);
    return SettingsBloc(mockSettings, mockExport);
  }

  setUp(() {
    mockSettings = MockSettingsService();
    mockExport = MockExportTimetableUseCase();
  });

  tearDown(() => bloc.close());

  // ── Initial state ────────────────────────────────────────────────────────────

  group('initial state', () {
    test('reads all three preferences from SettingsService on construction', () {
      bloc = buildBloc(
          storedTheme: 'dark', storedLanguage: 'fr', storedNotifications: false);
      expect(bloc.state.themeMode, ThemeMode.dark);
      expect(bloc.state.language, 'fr');
      expect(bloc.state.notificationsEnabled, false);
    });

    test('defaults to system / en / true / idle when nothing is stored', () {
      bloc = buildBloc();
      expect(bloc.state.themeMode, ThemeMode.system);
      expect(bloc.state.language, 'en');
      expect(bloc.state.notificationsEnabled, true);
      expect(bloc.state.exportStatus, ExportStatus.idle);
    });

    test('falls back to ThemeMode.system for an unknown stored value', () {
      bloc = buildBloc(storedTheme: 'unknown');
      expect(bloc.state.themeMode, ThemeMode.system);
    });
  });

  // ── SettingsThemeChanged ─────────────────────────────────────────────────────

  group('SettingsThemeChanged', () {
    setUp(() {
      bloc = buildBloc();
      when(() => mockSettings.setThemeMode(any())).thenAnswer((_) async {});
    });

    test('persists the new theme via SettingsService', () async {
      bloc.add(const SettingsThemeChanged(ThemeMode.dark));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockSettings.setThemeMode('dark')).called(1);
    });

    test('emits updated themeMode', () async {
      bloc.add(const SettingsThemeChanged(ThemeMode.light));
      await expectLater(
        bloc.stream,
        emits(isA<SettingsState>()
            .having((s) => s.themeMode, 'themeMode', ThemeMode.light)),
      );
    });

    test('does not alter language or notifications', () async {
      bloc = buildBloc(storedLanguage: 'fr', storedNotifications: false);
      when(() => mockSettings.setThemeMode(any())).thenAnswer((_) async {});
      bloc.add(const SettingsThemeChanged(ThemeMode.dark));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.language, 'fr');
      expect(bloc.state.notificationsEnabled, false);
    });
  });

  // ── SettingsLanguageChanged ──────────────────────────────────────────────────

  group('SettingsLanguageChanged', () {
    setUp(() {
      bloc = buildBloc();
      when(() => mockSettings.setLanguage(any())).thenAnswer((_) async {});
    });

    test('persists the new language code via SettingsService', () async {
      bloc.add(const SettingsLanguageChanged('fr'));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockSettings.setLanguage('fr')).called(1);
    });

    test('emits updated language', () async {
      bloc.add(const SettingsLanguageChanged('ar'));
      await expectLater(
        bloc.stream,
        emits(isA<SettingsState>()
            .having((s) => s.language, 'language', 'ar')),
      );
    });

    test('does not alter themeMode or notifications', () async {
      bloc = buildBloc(storedTheme: 'dark', storedNotifications: false);
      when(() => mockSettings.setLanguage(any())).thenAnswer((_) async {});
      bloc.add(const SettingsLanguageChanged('fr'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, ThemeMode.dark);
      expect(bloc.state.notificationsEnabled, false);
    });
  });

  // ── SettingsNotificationsChanged ─────────────────────────────────────────────

  group('SettingsNotificationsChanged', () {
    setUp(() {
      bloc = buildBloc();
      when(() => mockSettings.setNotificationsEnabled(any()))
          .thenAnswer((_) async {});
    });

    test('persists false via SettingsService when disabled', () async {
      bloc.add(const SettingsNotificationsChanged(false));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockSettings.setNotificationsEnabled(false)).called(1);
    });

    test('emits notificationsEnabled = false', () async {
      bloc.add(const SettingsNotificationsChanged(false));
      await expectLater(
        bloc.stream,
        emits(isA<SettingsState>().having(
            (s) => s.notificationsEnabled, 'notificationsEnabled', false)),
      );
    });

    test('re-enabling persists true', () async {
      bloc = buildBloc(storedNotifications: false);
      when(() => mockSettings.setNotificationsEnabled(any()))
          .thenAnswer((_) async {});
      bloc.add(const SettingsNotificationsChanged(true));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockSettings.setNotificationsEnabled(true)).called(1);
    });

    test('does not alter themeMode or language', () async {
      bloc = buildBloc(storedTheme: 'dark', storedLanguage: 'fr');
      when(() => mockSettings.setNotificationsEnabled(any()))
          .thenAnswer((_) async {});
      bloc.add(const SettingsNotificationsChanged(false));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.themeMode, ThemeMode.dark);
      expect(bloc.state.language, 'fr');
    });
  });

  // ── ExportTimetableRequested ─────────────────────────────────────────────────

  group('ExportTimetableRequested', () {
    setUp(() => bloc = buildBloc());

    test('emits loading then success on successful export', () async {
      when(() => mockExport()).thenAnswer((_) async => right('path/to/file'));

      bloc.add(const ExportTimetableRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SettingsState>()
              .having((s) => s.exportStatus, 'status', ExportStatus.loading),
          isA<SettingsState>()
              .having((s) => s.exportStatus, 'status', ExportStatus.success),
        ]),
      );
    });

    test('emits loading then failure on export error', () async {
      when(() => mockExport()).thenAnswer(
        (_) async => left(const CacheException('disk full')),
      );

      bloc.add(const ExportTimetableRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<SettingsState>()
              .having((s) => s.exportStatus, 'status', ExportStatus.loading),
          isA<SettingsState>()
              .having((s) => s.exportStatus, 'status', ExportStatus.failure)
              .having((s) => s.exportError, 'exportError', 'disk full'),
        ]),
      );
    });

    test('clears exportError when a new export starts', () async {
      // First attempt fails.
      when(() => mockExport()).thenAnswer(
        (_) async => left(const CacheException('disk full')),
      );
      bloc.add(const ExportTimetableRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.exportError, 'disk full');

      // Second attempt starts — loading state must have null exportError.
      when(() => mockExport()).thenAnswer((_) async => right('path'));
      bloc.add(const ExportTimetableRequested());

      await expectLater(
        bloc.stream,
        emits(isA<SettingsState>()
            .having((s) => s.exportStatus, 'status', ExportStatus.loading)
            .having((s) => s.exportError, 'exportError', isNull)),
      );
    });

    test('calls ExportTimetableUseCase exactly once per event', () async {
      when(() => mockExport()).thenAnswer((_) async => right('path'));
      bloc.add(const ExportTimetableRequested());
      await Future<void>.delayed(Duration.zero);
      verify(() => mockExport()).called(1);
    });
  });

  // ── SettingsState ────────────────────────────────────────────────────────────

  group('SettingsState', () {
    test('copyWith updates only the specified field', () {
      const s = SettingsState(
        themeMode: ThemeMode.dark,
        language: 'fr',
        notificationsEnabled: false,
      );
      final updated = s.copyWith(language: 'ar');
      expect(updated.language, 'ar');
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.notificationsEnabled, false);
    });

    test('copyWith preserves exportError when not explicitly set', () {
      const s = SettingsState(
        exportStatus: ExportStatus.failure,
        exportError: 'disk full',
      );
      final updated = s.copyWith(exportStatus: ExportStatus.idle);
      expect(updated.exportError, 'disk full');
    });

    test('copyWith clears exportError when explicitly set to null', () {
      const s = SettingsState(exportError: 'disk full');
      final updated = s.copyWith(exportError: null);
      expect(updated.exportError, isNull);
    });

    test('two states with identical fields are equal', () {
      expect(
        const SettingsState(
            themeMode: ThemeMode.dark, language: 'fr', notificationsEnabled: false),
        const SettingsState(
            themeMode: ThemeMode.dark, language: 'fr', notificationsEnabled: false),
      );
    });

    test('states differing in language are not equal', () {
      expect(
        const SettingsState(language: 'en'),
        isNot(const SettingsState(language: 'fr')),
      );
    });
  });
}
