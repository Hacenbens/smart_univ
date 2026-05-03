part of 'settings_bloc.dart';

enum ExportStatus { idle, loading, success, failure }

final class SettingsState extends Equatable {
  // Sentinel so copyWith() can explicitly clear exportError to null.
  static const _keep = Object();

  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final ExportStatus exportStatus;
  final String? exportError;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.exportStatus = ExportStatus.idle,
    this.exportError,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    ExportStatus? exportStatus,
    Object? exportError = _keep,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        exportStatus: exportStatus ?? this.exportStatus,
        exportError:
            identical(exportError, _keep) ? this.exportError : exportError as String?,
      );

  @override
  List<Object?> get props =>
      [themeMode, language, notificationsEnabled, biometricEnabled, exportStatus, exportError];
}
