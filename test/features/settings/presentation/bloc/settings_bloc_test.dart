import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockSettingsService mockSettings;
  late SettingsBloc bloc;

  // Helper — builds a bloc whose service reports [storedValue] as the persisted theme.
  SettingsBloc buildBloc({String storedValue = 'system'}) {
    when(() => mockSettings.getThemeMode()).thenReturn(storedValue);
    return SettingsBloc(mockSettings);
  }

  setUp(() {
    mockSettings = MockSettingsService();
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('defaults to ThemeMode.system when nothing is stored', () {
      bloc = buildBloc(storedValue: 'system');
      expect(bloc.state.themeMode, ThemeMode.system);
    });

    test('restores ThemeMode.light from SharedPreferences on cold start', () {
      bloc = buildBloc(storedValue: 'light');
      expect(bloc.state.themeMode, ThemeMode.light);
    });

    test('restores ThemeMode.dark from SharedPreferences on cold start', () {
      bloc = buildBloc(storedValue: 'dark');
      expect(bloc.state.themeMode, ThemeMode.dark);
    });

    test('falls back to ThemeMode.system for an unknown stored value', () {
      bloc = buildBloc(storedValue: 'unknown_value');
      expect(bloc.state.themeMode, ThemeMode.system);
    });
  });

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

    test('emits state with updated themeMode', () async {
      bloc.add(const SettingsThemeChanged(ThemeMode.light));

      await expectLater(
        bloc.stream,
        emits(const SettingsState(themeMode: ThemeMode.light)),
      );
    });

    test('persists system mode as "system"', () async {
      bloc = buildBloc(storedValue: 'dark');
      when(() => mockSettings.setThemeMode(any())).thenAnswer((_) async {});

      bloc.add(const SettingsThemeChanged(ThemeMode.system));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockSettings.setThemeMode('system')).called(1);
    });

    test('each distinct mode change persists exactly once', () async {
      bloc.add(const SettingsThemeChanged(ThemeMode.dark));
      bloc.add(const SettingsThemeChanged(ThemeMode.light));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockSettings.setThemeMode('dark')).called(1);
      verify(() => mockSettings.setThemeMode('light')).called(1);
    });
  });

  group('SettingsState', () {
    test('copyWith updates themeMode', () {
      const s = SettingsState();
      expect(s.copyWith(themeMode: ThemeMode.dark).themeMode, ThemeMode.dark);
    });

    test('copyWith without args preserves themeMode', () {
      const s = SettingsState(themeMode: ThemeMode.light);
      expect(s.copyWith().themeMode, ThemeMode.light);
    });

    test('equal when themeMode matches', () {
      expect(
        const SettingsState(themeMode: ThemeMode.dark),
        const SettingsState(themeMode: ThemeMode.dark),
      );
    });

    test('not equal when themeMode differs', () {
      expect(
        const SettingsState(themeMode: ThemeMode.light),
        isNot(const SettingsState(themeMode: ThemeMode.dark)),
      );
    });
  });
}
