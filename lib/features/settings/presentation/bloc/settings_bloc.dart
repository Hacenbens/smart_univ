import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/services/biometric_service.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/domain/usecases/export_timetable_use_case.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settings;
  final ExportTimetableUseCase _exportTimetable;
  final NotificationService _notif;
  final BiometricService _biometric;

  SettingsBloc(this._settings, this._exportTimetable, this._notif, this._biometric)
      : super(
          SettingsState(
            themeMode: _themeModeFromString(_settings.getThemeMode()),
            language: _settings.getLanguage(),
            notificationsEnabled: _settings.getNotificationsEnabled(),
            biometricEnabled: _settings.getBiometricEnabled(),
          ),
        ) {
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsNotificationsChanged>(_onNotificationsChanged);
    on<ExportTimetableRequested>(_onExportTimetable);
    on<BiometricToggleRequested>(_onBiometricToggle);
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
    if (!event.enabled) await _notif.cancelAll();
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

  Future<void> _onBiometricToggle(
    BiometricToggleRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (!event.enabled) {
      await _settings.setBiometricEnabled(false);
      emit(state.copyWith(biometricEnabled: false, biometricError: null));
      return;
    }
    final available = await _biometric.isAvailable();
    if (!available) {
      emit(state.copyWith(biometricError: 'No biometrics enrolled on this device'));
      return;
    }
    final authenticated = await _biometric.authenticate();
    if (!authenticated) {
      emit(state.copyWith(biometricError: 'Biometric authentication failed or cancelled'));
      return;
    }
    await _settings.setBiometricEnabled(true);
    emit(state.copyWith(biometricEnabled: true, biometricError: null));
  }

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
