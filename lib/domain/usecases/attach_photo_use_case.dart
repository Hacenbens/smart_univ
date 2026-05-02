import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/either.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/camera_service.dart';
import 'package:smart_univ/core/services/permission_service.dart';
import 'package:smart_univ/core/usecases/use_case.dart';

enum PhotoSource { camera, gallery }

class AttachPhotoParams extends Equatable {
  final PhotoSource source;

  const AttachPhotoParams(this.source);

  @override
  List<Object?> get props => [source];
}

/// Checks/requests camera permission, then picks an image via [CameraService].
///
/// Returns [Right(path)] on success, [Right(null)] if the user cancelled,
/// or [Left(PermissionException)] if the permission is permanently denied.
class AttachPhotoUseCase implements UseCase<String?, AttachPhotoParams> {
  final CameraService _cameraService;
  final PermissionService _permissionService;

  AttachPhotoUseCase(this._cameraService, this._permissionService);

  @override
  Future<Either<AppException, String?>> call(AttachPhotoParams params) async {
    var permResult = await _permissionService.checkPermission(Permission.camera);

    if (permResult != PermissionResult.granted) {
      permResult = await _permissionService.requestPermission(Permission.camera);
    }

    if (permResult == PermissionResult.permanentlyDenied ||
        permResult == PermissionResult.restricted) {
      return left(const PermissionException('Camera permission permanently denied'));
    }

    if (permResult != PermissionResult.granted) {
      return right(null); // user tapped Deny — treat as cancel
    }

    final path = params.source == PhotoSource.camera
        ? await _cameraService.pickFromCamera()
        : await _cameraService.pickFromGallery();

    return right(path);
  }
}
