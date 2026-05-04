import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/widgets/widgets.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';
import 'package:smart_univ/features/events/presentation/pages/event_detail_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Discover', style: tt.labelLarge),
                        const SizedBox(height: 2),
                        Text('Events', style: tt.headlineMedium),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Submit'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) => switch (state) {
                  EventsInitial() => _buildInitial(context),
                  EventsLoading() =>
                    const LoadingWidget(message: 'Loading events…'),
                  EventsLoaded(:final events) when events.isEmpty =>
                    EmptyStateWidget(
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
            ),
          ],
        ),
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final bloc = context.read<EventsBloc>();
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _FeaturedEventCard(event: event, bloc: bloc),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EventListItem(event: event, index: index, bloc: bloc),
          );
        },
      ),
    );
  }
}

// ── Featured (first) event ───────────────────────────────────────────────────

class _FeaturedEventCard extends StatelessWidget {
  final Event event;
  final EventsBloc bloc;
  const _FeaturedEventCard({required this.event, required this.bloc});

  static const _accent = Color(0xFFC97A4A);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = event.startTime;
    final dateStr = '${weekdays[d.weekday - 1]} · ${months[d.month - 1]} ${d.day} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image placeholder
          Container(
            height: 148,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
            ),
            child: Stack(
              children: [
                // Striped pattern
                CustomPaint(
                  size: const Size(double.infinity, 148),
                  painter: _StripePainter(color: _accent),
                ),
                Center(
                  child: Text(
                    'EVENT PHOTO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _accent.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Chip(label: 'Featured', color: _accent),
                    const SizedBox(width: 6),
                    _Chip(label: dateStr, color: null),
                  ],
                ),
                const SizedBox(height: 10),
                Text(event.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text("I'm going"),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: EventDetailPage(eventId: event.id),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text('Photos'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming event row ───────────────────────────────────────────────────────

class _EventListItem extends StatelessWidget {
  final Event event;
  final int index;
  final EventsBloc bloc;
  const _EventListItem({required this.event, required this.index, required this.bloc});

  static const _tones = [
    Color(0xFF3F8240), // green
    Color(0xFFC97A4A), // clay
    Color(0xFF3D6FA8), // blue
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = event.startTime;
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final color = _tones[(index - 1) % _tones.length];

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: EventDetailPage(eventId: event.id),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Date block
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    weekdays[d.weekday - 1],
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: color),
                  ),
                  Text(
                    '${d.day}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.1, color: color),
                  ),
                  Text(
                    months[d.month - 1],
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color color;
  const _StripePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 8;
    for (double i = -size.height; i < size.width + size.height; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.color != color;
}
