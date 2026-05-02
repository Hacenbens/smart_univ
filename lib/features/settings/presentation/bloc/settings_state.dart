part of 'settings_bloc.dart';

enum ExportStatus { idle, loading, success, failure }

final class SettingsState extends Equatable {
  // Sentinel so copyWith() can explicitly clear exportError to null.
  static const _keep = Object();

  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final ExportStatus exportStatus;
  final String? exportError;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.exportStatus = ExportStatus.idle,
    this.exportError,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    ExportStatus? exportStatus,
    Object? exportError = _keep,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        exportStatus: exportStatus ?? this.exportStatus,
        exportError:
            identical(exportError, _keep) ? this.exportError : exportError as String?,
      );

  @override
  List<Object?> get props =>
      [themeMode, language, notificationsEnabled, exportStatus, exportError];
}
