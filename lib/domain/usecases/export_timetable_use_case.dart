import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/repositories/timetable_repository.dart';

class ExportTimetableUseCase {
  static const _fileName = 'timetable_export.json';

  final TimetableRepository _repository;
  final Future<Directory> Function() _getDocsDir;
  final Future<void> Function(List<XFile> files) _shareFiles;

  ExportTimetableUseCase(
    this._repository, {
    Future<Directory> Function()? getDocsDir,
    Future<void> Function(List<XFile>)? shareFiles,
  })  : _getDocsDir = getDocsDir ?? getApplicationDocumentsDirectory,
        _shareFiles = shareFiles ?? ((files) => Share.shareXFiles(files));

  Future<Either<AppException, String>> call() async {
    final result = await _repository.getTimetable();

    // Propagate repository failure immediately.
    late final List<TimetableItem> items;
    final failure = result.fold<AppException?>(
      (e) => e,
      (list) {
        items = list;
        return null;
      },
    );
    if (failure != null) return left(failure);

    try {
      final jsonString = jsonEncode(items.map(_itemToJson).toList());

      final dir = await _getDocsDir();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(jsonString);

      await _shareFiles([XFile(file.path)]);

      return right(file.path);
    } catch (e) {
      return left(CacheException('Timetable export failed: $e'));
    }
  }

  Map<String, dynamic> _itemToJson(TimetableItem item) => {
        'id': item.id,
        'subject': item.subject,
        'room': item.room,
        'instructor': item.instructor,
        'dayOfWeek': item.dayOfWeek,
        'startTime': item.startTime.toIso8601String(),
        'endTime': item.endTime.toIso8601String(),
      };
}
