import 'package:flutter/material.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/data/local/app_database.dart';
import 'package:smart_univ/data/local/daos/timetable_dao.dart';

class TimetableDetailScreen extends StatefulWidget {
  final int id;
  const TimetableDetailScreen({super.key, required this.id});

  @override
  State<TimetableDetailScreen> createState() => _TimetableDetailScreenState();
}

class _TimetableDetailScreenState extends State<TimetableDetailScreen> {
  TimetableRow? _item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    sl<TimetableDao>().getById(widget.id).then((row) {
      if (mounted) setState(() { _item = row; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Class Detail')),
        body: const Center(child: Text('Class not found')),
      );
    }
    final item = _item!;
    return Scaffold(
      appBar: AppBar(title: Text(item.courseCode)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Course', value: item.courseCode),
            const SizedBox(height: 16),
            _InfoRow(label: 'Room', value: item.room),
            const SizedBox(height: 16),
            _InfoRow(label: 'Time', value: '${item.startHour}:00'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
