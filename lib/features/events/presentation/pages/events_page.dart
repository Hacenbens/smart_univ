import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/widgets/widgets.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) => switch (state) {
          EventsInitial() => _buildInitial(context),
          EventsLoading() => const LoadingWidget(message: 'Loading events…'),
          EventsLoaded(:final events) when events.isEmpty => EmptyStateWidget(
              icon: Icons.event_busy_outlined,
              title: 'No upcoming events',
              subtitle: 'New events will appear here.',
              actionLabel: 'Refresh',
              onAction: () =>
                  context.read<EventsBloc>().add(const EventsRequested()),
            ),
          EventsLoaded(:final events) => _EventList(events: events),
          EventsFailure(:final message) => AppErrorWidget(
              title: 'Could not load events',
              message: message,
              onRetry: () =>
                  context.read<EventsBloc>().add(const EventsRequested()),
            ),
        },
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    context.read<EventsBloc>().add(const EventsRequested());
    return const LoadingWidget();
  }
}

class _EventList extends StatelessWidget {
  final List<Event> events;

  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<EventsBloc>().add(const EventsRequested()),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _EventCard(event: events[index]),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: tt.titleMedium),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: cs.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: tt.labelSmall?.copyWith(color: cs.outline),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.schedule_outlined, size: 14, color: cs.outline),
                const SizedBox(width: 4),
                Text(
                  _formatTime(event.startTime),
                  style: tt.labelSmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
