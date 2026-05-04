import 'package:flutter/services.dart';

class ScreenSecurityService {
  static const _channel = MethodChannel('com.smartcampus/screen_security');

  /// Enables FLAG_SECURE (Android) and the App Switcher blur (iOS).
  Future<void> enableSecure() => _channel.invokeMethod('setSecure');

  /// Removes the secure flag — call this when leaving a sensitive screen.
  Future<void> disableSecure() => _channel.invokeMethod('clearSecure');
}
