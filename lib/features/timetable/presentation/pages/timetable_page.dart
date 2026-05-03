import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/services/notification_service.dart';
import 'package:smart_univ/core/services/settings_service.dart';
import 'package:smart_univ/features/timetable/presentation/bloc/timetable_bloc.dart';

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
    context.read<TimetableBloc>().add(const TimetableRequested());
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
      body: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) => switch (state) {
          TimetableInitial() || TimetableLoading() =>
            const Center(child: CircularProgressIndicator()),
          TimetableLoaded(:final items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Theme.of(context).colorScheme.error,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => context
                      .read<TimetableBloc>()
                      .add(TimetableItemDeleted(item)),
                  child: ListTile(
                    title: Text(item.subject),
                    subtitle: Text('${item.room} • ${item.instructor}'),
                    trailing: Text(
                      '${TimeOfDay.fromDateTime(item.startTime).format(context)}'
                      ' – '
                      '${TimeOfDay.fromDateTime(item.endTime).format(context)}',
                    ),
                  ),
                );
              },
            ),
          TimetableFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<TimetableBloc>()
                        .add(const TimetableRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}
