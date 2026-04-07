import 'package:flutter/material.dart';

/// Full-area empty state.
///
/// Use when a list or data source has no items to show.
///
/// ```dart
/// EmptyStateWidget(
///   title: 'No announcements yet',
///   subtitle: 'Check back later for updates.',
/// )
///
/// EmptyStateWidget(
///   icon: Icons.event_busy_outlined,
///   title: 'No upcoming events',
///   subtitle: 'New events will appear here.',
///   actionLabel: 'Refresh',
///   onAction: () => bloc.add(const EventsRequested()),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SoftIconBadge(
                icon: icon,
                backgroundColor: cs.secondaryContainer,
                iconColor: cs.onSecondaryContainer,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: tt.headlineMedium?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  static const double _size = 72;

  const _SoftIconBadge({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: _size * 0.5, color: iconColor),
    );
  }
}
