import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/domain/usecases/export_timetable_use_case.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settings;
  final ExportTimetableUseCase _exportTimetable;

  SettingsBloc(this._settings, this._exportTimetable)
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
    on<ExportTimetableRequested>(_onExportTimetable);
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

  Future<void> _onExportTimetable(
    ExportTimetableRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      exportStatus: ExportStatus.loading,
      exportError: null,
    ));

    final result = await _exportTimetable();

    result.fold(
      (failure) => emit(state.copyWith(
        exportStatus: ExportStatus.failure,
        exportError: failure.message,
      )),
      (_) => emit(state.copyWith(exportStatus: ExportStatus.success)),
    );
  }

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
