import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_univ/domain/entities/event.dart';
import 'package:smart_univ/domain/usecases/attach_photo_use_case.dart';
import 'package:smart_univ/features/events/presentation/bloc/events_bloc.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

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
            ? state.events.where((e) => e.id == eventId).firstOrNull
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(event?.title ?? ''),
            actions: [
              if (event != null)
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined),
                  tooltip: 'Attach Photo',
                  onPressed: () => _showSourcePicker(context, eventId),
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

  void _showSourcePicker(BuildContext context, String eventId) {
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
                eventId: eventId,
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
                eventId: eventId,
                source: PhotoSource.gallery,
              ));
            },
          ),
        ],
      ),
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
