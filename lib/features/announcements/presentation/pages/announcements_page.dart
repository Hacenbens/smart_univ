import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/core/widgets/widgets.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/features/announcements/presentation/bloc/announcements_bloc.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) => switch (state) {
          AnnouncementsInitial() => _buildInitial(context),
          AnnouncementsLoading() => const LoadingWidget(message: 'Loading announcements…'),
          AnnouncementsLoaded(:final announcements) when announcements.isEmpty =>
            EmptyStateWidget(
              icon: Icons.campaign_outlined,
              title: 'No announcements',
              subtitle: 'Check back later for updates.',
              actionLabel: 'Refresh',
              onAction: () => context.read<AnnouncementsBloc>().add(const AnnouncementsRequested()),
            ),
          AnnouncementsLoaded(:final announcements) =>
            _AnnouncementList(announcements: announcements),
          AnnouncementsFailure(:final message) => AppErrorWidget(
              title: 'Could not load announcements',
              message: message,
              onRetry: () => context.read<AnnouncementsBloc>().add(const AnnouncementsRequested()),
            ),
        },
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
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _AnnouncementCard(announcement: announcements[index]),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

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
            Text(announcement.title, style: tt.titleMedium),
            const SizedBox(height: 6),
            Text(
              announcement.body,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: cs.outline),
                const SizedBox(width: 4),
                Text(announcement.authorName,
                    style: tt.labelSmall?.copyWith(color: cs.outline)),
                const Spacer(),
                Text(
                  _formatDate(announcement.publishedAt),
                  style: tt.labelSmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
