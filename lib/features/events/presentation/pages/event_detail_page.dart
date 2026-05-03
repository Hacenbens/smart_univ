import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/services/permission_lifecycle_mixin.dart';
import 'package:smart_univ/core/services/permission_service.dart';
import 'package:smart_univ/core/widgets/rationale_dialog.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/usecases/attach_photo_use_case.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with WidgetsBindingObserver, PermissionLifecycleMixin<EventDetailPage> {
  PermissionResult? _cameraPermission;

  // ── PermissionLifecycleMixin contract ──────────────────────────────────────

  @override
  Permission get observedPermission => Permission.camera;

  @override
  PermissionService get permissionService => sl<PermissionService>();

  @override
  void onPermissionStatusChanged(PermissionResult result) {
    setState(() => _cameraPermission = result);
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState(); // mixin registers WidgetsBindingObserver
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final result = await sl<PermissionService>().checkPermission(Permission.camera);
    if (mounted) setState(() => _cameraPermission = result);
  }

  // ── Camera gate ────────────────────────────────────────────────────────────

  Future<void> _onAttachPhotoTapped() async {
    final permission =
        _cameraPermission ??
        await sl<PermissionService>().checkPermission(Permission.camera);
    if (!mounted) return;

    switch (permission) {
      case PermissionResult.granted:
        _showSourcePicker();
      case PermissionResult.denied:
        _showCameraRationale();
      case PermissionResult.permanentlyDenied:
      case PermissionResult.restricted:
        _showCameraPermanentlyDenied();
    }
  }

  void _showCameraRationale() {
    showDialog<void>(
      context: context,
      builder: (ctx) => RationaleDialog(
        title: 'Camera Access',
        body: 'SmartCampus needs camera access to attach photos to event notes.',
        allowLabel: 'Continue',
        onAllow: () async {
          Navigator.of(ctx).pop();
          final result =
              await sl<PermissionService>().requestPermission(Permission.camera);
          if (!mounted) return;
          setState(() => _cameraPermission = result);
          if (result == PermissionResult.granted) {
            _showSourcePicker();
          } else {
            // Second denial — fall back gracefully without re-prompting.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera access denied')),
            );
          }
        },
        onDeny: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showCameraPermanentlyDenied() {
    showDialog<void>(
      context: context,
      builder: (ctx) => RationaleDialog(
        title: 'Camera Access Blocked',
        body: 'Camera access was permanently denied. Enable it in Settings to attach photos to event notes.',
        allowLabel: 'Open Settings',
        denyLabel: 'Cancel',
        onAllow: () {
          Navigator.of(ctx).pop();
          sl<PermissionService>().openSettings();
        },
        onDeny: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showSourcePicker() {
    final bloc = context.read<EventsBloc>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.of(sheetCtx).pop();
              bloc.add(AttachPhotoRequested(
                eventId: widget.eventId,
                source: PhotoSource.camera,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.of(sheetCtx).pop();
              bloc.add(AttachPhotoRequested(
                eventId: widget.eventId,
                source: PhotoSource.gallery,
              ));
            },
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsBloc, EventsState>(
      listenWhen: (previous, current) {
        final prevErr =
            previous is EventsLoaded ? previous.photoAttachError : null;
        final currErr =
            current is EventsLoaded ? current.photoAttachError : null;
        return currErr != null && currErr != prevErr;
      },
      listener: (context, state) {
        if (state is EventsLoaded && state.photoAttachError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.photoAttachError!)),
          );
        }
      },
      builder: (context, state) {
        final event = state is EventsLoaded
            ? state.events.where((e) => e.id == widget.eventId).firstOrNull
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(event?.title ?? ''),
            actions: [
              if (event != null)
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined),
                  tooltip: 'Attach Photo',
                  onPressed: _onAttachPhotoTapped,
                ),
            ],
          ),
          body: event != null
              ? _EventDetailBody(event: event)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  final Event event;

  const _EventDetailBody({required this.event});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(event.photoPath!),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(event.title, style: tt.headlineSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: cs.outline),
              const SizedBox(width: 4),
              Text(event.location, style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule_outlined, size: 16, color: cs.outline),
              const SizedBox(width: 4),
              Text(_formatDateTime(event.startTime), style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(event.description, style: tt.bodyLarge),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
