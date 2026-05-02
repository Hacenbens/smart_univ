import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/settings_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settings;

  SettingsBloc(this._settings)
      : super(
          SettingsState(
            themeMode: _themeModeFromString(_settings.getThemeMode()),
            language: _settings.getLanguage(),
            notificationsEnabled: _settings.getNotificationsEnabled(),
          ),
        ) {
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsNotificationsChanged>(_onNotificationsChanged);
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _settings.setThemeMode(event.themeMode.name);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _settings.setLanguage(event.languageCode);
    emit(state.copyWith(language: event.languageCode));
  }

  Future<void> _onNotificationsChanged(
    SettingsNotificationsChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _settings.setNotificationsEnabled(event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
