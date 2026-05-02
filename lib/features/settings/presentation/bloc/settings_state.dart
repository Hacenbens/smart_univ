part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  @override
  List<Object?> get props => [themeMode, language, notificationsEnabled];
}
