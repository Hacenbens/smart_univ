import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotifications = 'notifications_enabled';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyTheme, mode);

  String getThemeMode() => _prefs.getString(_keyTheme) ?? 'system';

  Future<void> setLanguage(String code) =>
      _prefs.setString(_keyLanguage, code);

  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'en';

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotifications, value);

  bool getNotificationsEnabled() =>
      _prefs.getBool(_keyNotifications) ?? true;

  /// `true` once [setNotificationsEnabled] has been called at least once,
  /// meaning the permission prompt has already been shown to the user.
  bool get hasRequestedNotificationPermission =>
      _prefs.containsKey(_keyNotifications);
}
