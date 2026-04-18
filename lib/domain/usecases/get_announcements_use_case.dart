import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/usecases/use_case.dart';
import 'package:smart_univ/domain/entities/announcement.dart';
import 'package:smart_univ/domain/repositories/announcement_repository.dart';

class GetAnnouncementsUseCase
    implements UseCase<List<Announcement>, NoParams> {
  final AnnouncementRepository _repository;

  GetAnnouncementsUseCase(this._repository);

  @override
  Future<Either<AppException, List<Announcement>>> call(NoParams params) =>
      _repository.getAnnouncements();
}
