import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _classRemindersChannelId = 'class_reminders';
  static const _announcementsChannelId = 'announcements';

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );
    await _createAndroidChannels();
  }

  Future<void> _createAndroidChannels() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (impl == null) return;
    await impl.createNotificationChannel(const AndroidNotificationChannel(
      _classRemindersChannelId,
      'Class Reminders',
      importance: Importance.high,
    ));
    await impl.createNotificationChannel(const AndroidNotificationChannel(
      _announcementsChannelId,
      'Announcements',
      importance: Importance.defaultImportance,
    ));
  }

  /// Requests notification permission at the OS level.
  /// Returns `true` if the user granted permission.
  /// Call only from a contextually appropriate moment (e.g. Timetable screen).
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final darwin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (darwin != null) {
      return await darwin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  Future<void> showImmediate({
    required String title,
    required String body,
    String? payload,
    String channelId = _announcementsChannelId,
  }) async {
    try {
      await _plugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(channelId, channelId),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> scheduleAt({
    required int id,
    required tz.TZDateTime time,
    required String title,
    required String body,
    String? payload,
    String channelId = _classRemindersChannelId,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        time,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
