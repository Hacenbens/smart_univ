import 'dart:developer';

import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class AnnouncementSyncUseCase {
  final AnnouncementRepository _repository;

  AnnouncementSyncUseCase(this._repository);

  Future<void> call() async {
    try {
      final result = await _repository.getAnnouncements();
      result.fold(
        (e) => log('AnnouncementSyncUseCase: $e'),
        (_) {},
      );
    } catch (e, st) {
      log('AnnouncementSyncUseCase: unexpected error: $e', stackTrace: st);
    }
  }
}
