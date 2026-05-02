import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Gateway for picking images from the camera or device gallery.
///
/// Both methods apply [imageQuality] 80 and [maxWidth] 1080 to cap file size —
/// full-resolution photos can exceed 8 MB, which is unnecessary for thumbnails.
///
/// Returns the local file path on success, or `null` if the user cancelled.
class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Opens the device camera and returns the captured image path, or `null` on cancel.
  Future<String?> pickFromCamera() async {
    final file = await executePick(ImageSource.camera);
    return file?.path;
  }

  /// Opens the system gallery picker and returns the selected image path, or `null` on cancel.
  Future<String?> pickFromGallery() async {
    final file = await executePick(ImageSource.gallery);
    return file?.path;
  }

  // ── Platform-call seam (overridable in tests) ───────────────────────────────

  /// Calls [ImagePicker.pickImage] — opens the system UI.
  /// Override in tests to avoid hitting the platform channel.
  @visibleForTesting
  Future<XFile?> executePick(ImageSource source) => _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
}
