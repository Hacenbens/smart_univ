import 'package:flutter/material.dart';

/// Full-area error state.
///
/// Shows a soft icon, title, optional detail message, and an optional
/// retry button. Use whenever a BLoC emits a failure state.
///
/// ```dart
/// AppErrorWidget(
///   title: 'Could not load announcements',
///   message: error.message,
///   onRetry: () => bloc.add(const AnnouncementsRequested()),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
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
              _IconBadge(
                icon: Icons.error_outline_rounded,
                backgroundColor: cs.errorContainer,
                iconColor: cs.onErrorContainer,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: tt.headlineMedium?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(retryLabel),
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

/// Soft circular icon badge — shared between error and empty state.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  static const double _size = 72;

  const _IconBadge({
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
