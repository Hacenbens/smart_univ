import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/widgets/widgets.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/home/presentation/bloc/home_bloc.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  static const _filterLabels = [
    (AnnouncementFilter.all, 'All'),
    (AnnouncementFilter.pinned, 'Pinned'),
    (AnnouncementFilter.academic, 'Academic'),
    (AnnouncementFilter.campusLife, 'Campus life'),
    (AnnouncementFilter.services, 'Services'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeShakeDetected) {
          context.read<AnnouncementsBloc>().add(const AnnouncementsRefreshRequested());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Inbox', style: tt.labelLarge),
                          const SizedBox(height: 2),
                          Text('Announcements', style: tt.headlineMedium),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Icon(Icons.search_outlined, size: 20, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              // Filter chips — driven by bloc state
              BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
                buildWhen: (prev, curr) =>
                    (prev is AnnouncementsLoaded ? prev.activeFilter : null) !=
                    (curr is AnnouncementsLoaded ? curr.activeFilter : null),
                builder: (context, state) {
                  final active = state is AnnouncementsLoaded
                      ? state.activeFilter
                      : AnnouncementFilter.all;
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filterLabels.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final (filter, label) = _filterLabels[i];
                        final selected = active == filter;
                        return FilterChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => context
                              .read<AnnouncementsBloc>()
                              .add(AnnouncementFilterChanged(filter)),
                          selectedColor: cs.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : cs.onSurfaceVariant,
                          ),
                          backgroundColor: cs.surface,
                          side: BorderSide(color: cs.outlineVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          showCheckmark: false,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Expanded(
                child: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
                  builder: (context, state) => switch (state) {
                    AnnouncementsInitial() => _buildInitial(context),
                    AnnouncementsLoading() =>
                      const LoadingWidget(message: 'Loading announcements…'),
                    AnnouncementsLoaded() when state.filtered.isEmpty =>
                      EmptyStateWidget(
                        icon: Icons.campaign_outlined,
                        title: state.allAnnouncements.isEmpty
                            ? 'No announcements'
                            : 'No announcements here',
                        subtitle: state.allAnnouncements.isEmpty
                            ? 'Check back later for updates.'
                            : 'Try a different filter.',
                        actionLabel: state.allAnnouncements.isEmpty ? 'Refresh' : 'Show all',
                        onAction: () {
                          if (state.allAnnouncements.isEmpty) {
                            context
                                .read<AnnouncementsBloc>()
                                .add(const AnnouncementsRequested());
                          } else {
                            context
                                .read<AnnouncementsBloc>()
                                .add(const AnnouncementFilterChanged(AnnouncementFilter.all));
                          }
                        },
                      ),
                    AnnouncementsLoaded() =>
                      _AnnouncementList(announcements: state.filtered),
                    AnnouncementsFailure(:final message) => AppErrorWidget(
                        title: 'Could not load announcements',
                        message: message,
                        onRetry: () => context
                            .read<AnnouncementsBloc>()
                            .add(const AnnouncementsRequested()),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    context.read<AnnouncementsBloc>().add(const AnnouncementsRequested());
    return const LoadingWidget();
  }
}

class _AnnouncementList extends StatelessWidget {
  final List<Announcement> announcements;
  const _AnnouncementList({required this.announcements});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<AnnouncementsBloc>().add(const AnnouncementsRequested()),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _AnnouncementCard(announcement: announcements[index]),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  const _AnnouncementCard({required this.announcement});

  static Color _categoryColor(AnnouncementCategory cat) => switch (cat) {
        AnnouncementCategory.academic => const Color(0xFF3B82F6),
        AnnouncementCategory.campusLife => const Color(0xFF22C55E),
        AnnouncementCategory.services => const Color(0xFFA855F7),
        AnnouncementCategory.general => const Color(0xFFC97A4A),
      };

  static String _categoryLabel(AnnouncementCategory cat) => switch (cat) {
        AnnouncementCategory.academic => 'Academic',
        AnnouncementCategory.campusLife => 'Campus life',
        AnnouncementCategory.services => 'Services',
        AnnouncementCategory.general => 'General',
      };

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = _categoryColor(announcement.category);

    return Container(
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
            height: 70,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _categoryLabel(announcement.category),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (announcement.isPinned) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.push_pin, size: 13, color: cs.onSurfaceVariant),
                    ],
                    const Spacer(),
                    Text(
                      _timeAgo(announcement.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.body,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
