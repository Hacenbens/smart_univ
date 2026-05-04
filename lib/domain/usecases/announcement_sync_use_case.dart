import 'package:flutter/foundation.dart';

import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class AnnouncementSyncUseCase {
  final AnnouncementRepository _repository;

  AnnouncementSyncUseCase(this._repository);

  Future<void> call() async {
    try {
      final result = await _repository.getAnnouncements();
      result.fold(
        (e) {
          if (kDebugMode) debugPrint('AnnouncementSyncUseCase: $e');
        },
        (_) {},
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AnnouncementSyncUseCase: unexpected error: $e\n$st');
      }
    }
  }
}
