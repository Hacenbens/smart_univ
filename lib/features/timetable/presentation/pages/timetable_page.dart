import 'package:flutter/material.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/services/settings_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  void initState() {
    super.initState();
    _maybeRequestNotificationPermission();
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final settings = sl<SettingsService>();
    if (settings.hasRequestedNotificationPermission) return;
    final granted = await sl<NotificationService>().requestPermission();
    await settings.setNotificationsEnabled(granted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: const Center(
        child: Text('Timetable — coming soon'),
      ),
    );
  }
}
