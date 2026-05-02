import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_univ/core/services/camera_service.dart';

// Seam subclass that overrides only executePick so the real pickFromCamera /
// pickFromGallery logic runs end-to-end without hitting the platform channel.
class _SeamCameraService extends CameraService {
  final XFile? stubbedFile;

  ImageSource? capturedSource;

  _SeamCameraService({this.stubbedFile});

  @override
  Future<XFile?> executePick(ImageSource source) async {
    capturedSource = source;
    return stubbedFile;
  }
}

void main() {
  // ── pickFromCamera ────────────────────────────────────────────────────────────

  group('pickFromCamera', () {
    test('returns file path when image is captured', () async {
      final service = _SeamCameraService(stubbedFile: XFile('/tmp/photo.jpg'));

      final result = await service.pickFromCamera();

      expect(result, '/tmp/photo.jpg');
    });

    test('passes ImageSource.camera to executePick', () async {
      final service = _SeamCameraService(stubbedFile: XFile('/tmp/photo.jpg'));

      await service.pickFromCamera();

      expect(service.capturedSource, ImageSource.camera);
    });

    test('returns null when user cancels', () async {
      final service = _SeamCameraService(stubbedFile: null);

      final result = await service.pickFromCamera();

      expect(result, isNull);
    });
  });

  // ── pickFromGallery ───────────────────────────────────────────────────────────

  group('pickFromGallery', () {
    test('returns file path when image is selected', () async {
      final service = _SeamCameraService(stubbedFile: XFile('/tmp/gallery.jpg'));

      final result = await service.pickFromGallery();

      expect(result, '/tmp/gallery.jpg');
    });

    test('passes ImageSource.gallery to executePick', () async {
      final service = _SeamCameraService(stubbedFile: XFile('/tmp/gallery.jpg'));

      await service.pickFromGallery();

      expect(service.capturedSource, ImageSource.gallery);
    });

    test('returns null when user cancels', () async {
      final service = _SeamCameraService(stubbedFile: null);

      final result = await service.pickFromGallery();

      expect(result, isNull);
    });
  });

  // ── source isolation ──────────────────────────────────────────────────────────

  group('source isolation', () {
    test('pickFromCamera and pickFromGallery use different sources', () async {
      final cameraService = _SeamCameraService(stubbedFile: XFile('/tmp/a.jpg'));
      final galleryService = _SeamCameraService(stubbedFile: XFile('/tmp/b.jpg'));

      await cameraService.pickFromCamera();
      await galleryService.pickFromGallery();

      expect(cameraService.capturedSource, ImageSource.camera);
      expect(galleryService.capturedSource, ImageSource.gallery);
      expect(cameraService.capturedSource, isNot(galleryService.capturedSource));
    });
  });
}
