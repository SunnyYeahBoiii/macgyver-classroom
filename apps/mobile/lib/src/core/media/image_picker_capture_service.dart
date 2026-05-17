import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../backend/repositories.dart';
import '../models.dart';

const _maxScanImageDimension = 1280.0;
const _scanImageQuality = 72;

class ImagePickerCaptureService implements ImageCaptureService {
  ImagePickerCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ScanImage?> captureCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _scanImageQuality,
      maxHeight: _maxScanImageDimension,
      maxWidth: _maxScanImageDimension,
    );
    if (file == null) return null;
    return _scanImageFromFile(file, 'camera');
  }

  @override
  Future<List<ScanImage>> pickGallery({int? limit}) async {
    final files = await _picker.pickMultiImage(
      imageQuality: _scanImageQuality,
      limit: limit,
      maxHeight: _maxScanImageDimension,
      maxWidth: _maxScanImageDimension,
    );
    return Future.wait([
      for (final file in files) _scanImageFromFile(file, 'gallery'),
    ]);
  }

  @override
  Future<List<ScanImage>> retrieveLostData() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const [];
    }
    final response = await _picker.retrieveLostData();
    final files = response.files;
    if (files == null || files.isEmpty) return const [];
    return Future.wait([
      for (final file in files) _scanImageFromFile(file, 'lost_data'),
    ]);
  }

  Future<ScanImage> _scanImageFromFile(XFile file, String source) async {
    final bytes = await file.readAsBytes();
    return ScanImage(
      id: file.name,
      source: source,
      path: file.path,
      mimeType: file.mimeType ?? _mimeTypeForPath(file.path),
      bytes: bytes,
    );
  }
}

String _mimeTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
