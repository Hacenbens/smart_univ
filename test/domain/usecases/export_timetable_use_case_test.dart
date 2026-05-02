import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/domain/entities/timetable_item.dart';
import 'package:smart_univ/domain/repositories/timetable_repository.dart';
import 'package:smart_univ/domain/usecases/export_timetable_use_case.dart';

class MockTimetableRepository extends Mock implements TimetableRepository {}

final _items = [
  TimetableItem(
    id: '1',
    subject: 'Mobile Development',
    room: 'Room 3A',
    instructor: 'Prof. Martin',
    dayOfWeek: 1,
    startTime: DateTime.utc(2024, 1, 8, 9),
    endTime: DateTime.utc(2024, 1, 8, 10, 30),
  ),
  TimetableItem(
    id: '2',
    subject: 'Algorithms',
    room: 'Room 2B',
    instructor: 'Prof. Benali',
    dayOfWeek: 2,
    startTime: DateTime.utc(2024, 1, 9, 11),
    endTime: DateTime.utc(2024, 1, 9, 12, 30),
  ),
];

void main() {
  late MockTimetableRepository mockRepo;
  late Directory tempDir;
  late List<XFile> capturedFiles;
  late ExportTimetableUseCase useCase;

  setUp(() async {
    mockRepo = MockTimetableRepository();
    tempDir = await Directory.systemTemp.createTemp('timetable_export_test_');
    capturedFiles = [];

    useCase = ExportTimetableUseCase(
      mockRepo,
      getDocsDir: () async => tempDir,
      shareFiles: (files) async => capturedFiles.addAll(files),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('ExportTimetableUseCase', () {
    group('on success', () {
      setUp(() {
        when(() => mockRepo.getTimetable())
            .thenAnswer((_) async => right(_items));
      });

      test('returns Right with the exported file path', () async {
        final result = await useCase();

        expect(result.isRight, isTrue);
        result.fold(
          (_) => fail('expected Right'),
          (path) => expect(path, endsWith('timetable_export.json')),
        );
      });

      test('writes timetable_export.json to the documents directory', () async {
        await useCase();

        final file = File('${tempDir.path}/timetable_export.json');
        expect(await file.exists(), isTrue);
      });

      test('JSON contains all timetable items', () async {
        await useCase();

        final content =
            await File('${tempDir.path}/timetable_export.json').readAsString();
        final decoded = jsonDecode(content) as List;

        expect(decoded.length, _items.length);
      });

      test('each JSON object contains the expected fields', () async {
        await useCase();

        final content =
            await File('${tempDir.path}/timetable_export.json').readAsString();
        final decoded = jsonDecode(content) as List;
        final first = decoded[0] as Map<String, dynamic>;

        expect(first['id'], '1');
        expect(first['subject'], 'Mobile Development');
        expect(first['room'], 'Room 3A');
        expect(first['instructor'], 'Prof. Martin');
        expect(first['dayOfWeek'], 1);
        expect(first['startTime'], '2024-01-08T09:00:00.000Z');
        expect(first['endTime'], '2024-01-08T10:30:00.000Z');
      });

      test('triggers the OS share sheet with the exported file', () async {
        await useCase();

        expect(capturedFiles, hasLength(1));
        expect(capturedFiles.first.path, endsWith('timetable_export.json'));
      });

      test('repository is called exactly once', () async {
        await useCase();
        verify(() => mockRepo.getTimetable()).called(1);
      });
    });

    group('on repository failure', () {
      test('returns Left and does not write a file', () async {
        when(() => mockRepo.getTimetable()).thenAnswer(
          (_) async => left(const NetworkException('offline')),
        );

        final result = await useCase();

        expect(result.isLeft, isTrue);
        result.fold(
          (e) => expect(e, isA<NetworkException>()),
          (_) => fail('expected Left'),
        );

        final file = File('${tempDir.path}/timetable_export.json');
        expect(await file.exists(), isFalse);
      });

      test('does not invoke the share sheet on failure', () async {
        when(() => mockRepo.getTimetable()).thenAnswer(
          (_) async => left(const NetworkException('offline')),
        );

        await useCase();

        expect(capturedFiles, isEmpty);
      });
    });
  });
}
