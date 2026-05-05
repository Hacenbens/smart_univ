import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_univ/features/timetable/presentation/bloc/timetable_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger data loads if not already loaded.
    final timetableState = context.watch<TimetableBloc>().state;
    final announcementsState = context.watch<AnnouncementsBloc>().state;

    if (timetableState is TimetableInitial) {
      context.read<TimetableBloc>().add(const TimetableRequested());
    }
    if (announcementsState is AnnouncementsInitial) {
      context.read<AnnouncementsBloc>().add(const AnnouncementsRequested());
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _GreetingHeader(),
                  const SizedBox(height: 20),
                  _NextClassCard(),
                  const SizedBox(height: 20),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  _TodaySchedule(),
                  const SizedBox(height: 24),
                  _AnnouncementsPreview(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Greeting header ──────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateLabel = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    final authState = context.watch<AuthBloc>().state;
    String firstName = 'Student';
    String initials = 'S';
    if (authState is AuthAuthenticated && authState.user != null) {
      final parts = authState.user!.fullName.trim().split(' ');
      firstName = parts.first;
      initials = parts
          .take(2)
          .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
          .join();
    }

    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel, style: tt.labelLarge),
              const SizedBox(height: 2),
              Text('$greeting, $firstName', style: tt.headlineMedium),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Next class hero card ─────────────────────────────────────────────────────

class _NextClassCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();

    final timetableState = context.watch<TimetableBloc>().state;

    TimetableItem? nextClass;
    if (timetableState is TimetableLoaded) {
      final todayItems = timetableState.items
          .where((i) => i.dayOfWeek == now.weekday)
          .where((i) => i.startTime.hour > now.hour ||
              (i.startTime.hour == now.hour && i.startTime.minute > now.minute))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (todayItems.isNotEmpty) nextClass = todayItems.first;
    }

    if (nextClass == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All done for today', style: tt.titleMedium),
                  Text('No more classes scheduled', style: tt.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final minUntil = nextClass.startTime.difference(now).inMinutes;
    final timeLabel = minUntil <= 0
        ? 'Now'
        : minUntil < 60
            ? 'in $minUntil min'
            : 'in ${(minUntil / 60).round()} h';

    final startH = nextClass.startTime.hour.toString().padLeft(2, '0');
    final startM = nextClass.startTime.minute.toString().padLeft(2, '0');
    final endH = nextClass.endTime.hour.toString().padLeft(2, '0');
    final endM = nextClass.endTime.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.85),
            cs.primary,
            cs.primaryContainer.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next class · $timeLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.white70,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Lecture',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nextClass.subject,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$startH:$startM – $endH:$endM · ${nextClass.room} · ${nextClass.instructor}',
            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go('/map'),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Get directions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  static const _actions = [
    (Icons.calendar_today_outlined, 'Schedule', '/timetable'),
    (Icons.campaign_outlined, 'Announcements', '/announcements'),
    (Icons.event_outlined, 'Events', '/events'),
    (Icons.map_outlined, 'Map', '/map'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _actions.map((action) {
            final (icon, label, route) = action;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: action != _actions.last ? 10 : 0,
                ),
                child: GestureDetector(
                  onTap: () => context.go(route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Today's schedule ─────────────────────────────────────────────────────────

class _TodaySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();

    final timetableState = context.watch<TimetableBloc>().state;

    List<TimetableItem> todayItems = [];
    if (timetableState is TimetableLoaded) {
      todayItems = timetableState.items
          .where((i) => i.dayOfWeek == now.weekday)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TODAY',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/timetable'),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: todayItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No classes scheduled today', style: tt.bodyMedium),
                )
              : Column(
                  children: todayItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isLast = i == todayItems.length - 1;
                    final isPast = item.endTime.isBefore(now);
                    final h = item.startTime.hour.toString().padLeft(2, '0');
                    final m = item.startTime.minute.toString().padLeft(2, '0');
                    final dur = item.endTime.difference(item.startTime).inMinutes;

                    // Cycle colors: primary, accent (orange), info (blue)
                    final colors = [cs.primary, const Color(0xFFC97A4A), const Color(0xFF3D6FA8)];
                    final color = colors[i % colors.length];

                    return Opacity(
                      opacity: isPast ? 0.55 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(bottom: BorderSide(color: cs.outlineVariant)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 48,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$h:$m',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    '$dur m',
                                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(width: 3, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Lecture',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(item.room, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

// ── Announcements preview ────────────────────────────────────────────────────

class _AnnouncementsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final annState = context.watch<AnnouncementsBloc>().state;

    Announcement? first;
    int count = 0;
    if (annState is AnnouncementsLoaded && annState.allAnnouncements.isNotEmpty) {
      first = annState.allAnnouncements.first;
      count = annState.allAnnouncements.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ANNOUNCEMENTS',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/announcements'),
              child: Text(
                count > 0 ? '$count new' : 'See all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (first == null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text('No announcements yet', style: tt.bodyMedium),
          )
        else
          GestureDetector(
            onTap: () => context.go('/announcements'),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97A4A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC97A4A).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            first.authorName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC97A4A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(first.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(
                          first.body,
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
