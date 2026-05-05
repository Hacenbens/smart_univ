part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  const SettingsThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

final class SettingsLanguageChanged extends SettingsEvent {
  final String languageCode;

  const SettingsLanguageChanged(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

final class SettingsNotificationsChanged extends SettingsEvent {
  final bool enabled;

  const SettingsNotificationsChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

final class ExportTimetableRequested extends SettingsEvent {
  const ExportTimetableRequested();
}

final class BiometricToggleRequested extends SettingsEvent {
  final bool enabled;

  const BiometricToggleRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
