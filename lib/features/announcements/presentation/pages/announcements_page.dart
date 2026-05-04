import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/widgets/widgets.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:smart_univ/features/home/presentation/bloc/home_bloc.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  int _selectedFilter = 0;

  static const _filters = ['All', 'Pinned', 'Academic', 'Campus life', 'Services'];

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
              // Header
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
              // Filter chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => FilterChip(
                    label: Text(_filters[i]),
                    selected: _selectedFilter == i,
                    onSelected: (_) => setState(() => _selectedFilter = i),
                    selectedColor: cs.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedFilter == i ? Colors.white : cs.onSurfaceVariant,
                    ),
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.outlineVariant),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    showCheckmark: false,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // List
              Expanded(
                child: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
                  builder: (context, state) => switch (state) {
                    AnnouncementsInitial() => _buildInitial(context),
                    AnnouncementsLoading() =>
                      const LoadingWidget(message: 'Loading announcements…'),
                    AnnouncementsLoaded(:final announcements)
                        when announcements.isEmpty =>
                      EmptyStateWidget(
                        icon: Icons.campaign_outlined,
                        title: 'No announcements',
                        subtitle: 'Check back later for updates.',
                        actionLabel: 'Refresh',
                        onAction: () => context
                            .read<AnnouncementsBloc>()
                            .add(const AnnouncementsRequested()),
                      ),
                    AnnouncementsLoaded(:final announcements) =>
                      _AnnouncementList(announcements: announcements),
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

  static const _accentColor = Color(0xFFC97A4A);

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              color: _accentColor,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            announcement.authorName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
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
