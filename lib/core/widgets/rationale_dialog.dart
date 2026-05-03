import 'package:flutter/material.dart';

/// A reusable permission-rationale dialog.
///
/// Use for every permission flow so the UX is uniform:
/// - First denial: [allowLabel] = 'Continue', triggers a re-request.
/// - Permanently denied: [allowLabel] = 'Open Settings', deep-links to OS settings.
class RationaleDialog extends StatelessWidget {
  final String title;
  final String body;
  final String allowLabel;
  final String denyLabel;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const RationaleDialog({
    super.key,
    required this.title,
    required this.body,
    this.allowLabel = 'Allow',
    this.denyLabel = 'Not Now',
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: Text(denyLabel),
        ),
        ElevatedButton(
          onPressed: onAllow,
          child: Text(allowLabel),
        ),
      ],
    );
  }
}
