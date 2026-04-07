import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  late SettingsBloc bloc;

  setUp(() => bloc = SettingsBloc());
  tearDown(() => bloc.close());

  group('SettingsBloc', () {
    group('initial state', () {
      test('themeMode is ThemeMode.system', () {
        expect(bloc.state.themeMode, ThemeMode.system);
      });
    });

    group('ToggleTheme', () {
      test('system → light on first toggle', () async {
        bloc.add(const ToggleTheme());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.themeMode, ThemeMode.light);
      });

      test('light → dark on second toggle', () async {
        bloc
          ..add(const ToggleTheme())
          ..add(const ToggleTheme());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.themeMode, ThemeMode.dark);
      });

      test('dark → system on third toggle (full cycle)', () async {
        bloc
          ..add(const ToggleTheme())
          ..add(const ToggleTheme())
          ..add(const ToggleTheme());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.themeMode, ThemeMode.system);
      });
    });

    group('SettingsState', () {
      test('copyWith returns updated themeMode', () {
        const s = SettingsState();
        final updated = s.copyWith(themeMode: ThemeMode.dark);
        expect(updated.themeMode, ThemeMode.dark);
      });

      test('copyWith without args returns same themeMode', () {
        const s = SettingsState(themeMode: ThemeMode.light);
        expect(s.copyWith().themeMode, ThemeMode.light);
      });

      test('two states with same themeMode are equal', () {
        expect(
          const SettingsState(themeMode: ThemeMode.dark),
          const SettingsState(themeMode: ThemeMode.dark),
        );
      });

      test('two states with different themeMode are not equal', () {
        expect(
          const SettingsState(themeMode: ThemeMode.light),
          isNot(const SettingsState(themeMode: ThemeMode.dark)),
        );
      });
    });
  });
}
