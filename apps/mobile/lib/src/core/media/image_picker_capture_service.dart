import 'package:image_picker/image_picker.dart';

import '../backend/repositories.dart';
import '../models.dart';

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ScanImage?> captureCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null) return null;
    return ScanImage(id: file.name, source: 'camera', path: file.path);
  }

  @override
  Future<List<ScanImage>> pickGallery() async {
    final files = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
    );
    return [
      for (final file in files)
        ScanImage(id: file.name, source: 'gallery', path: file.path),
    ];
  }

  @override
  Future<List<ScanImage>> retrieveLostData() async {
    final response = await _picker.retrieveLostData();
    final files = response.files;
    if (files == null || files.isEmpty) return const [];
    return [
      for (final file in files)
        ScanImage(id: file.name, source: 'lost_data', path: file.path),
    ];
  }
}
