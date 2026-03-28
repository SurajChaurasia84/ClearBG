import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum ClearBgImageSource { camera, gallery }

class PickedImageData {
  const PickedImageData({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

class ImagePickerService {
  ImagePickerService() : _picker = ImagePicker();

  final ImagePicker _picker;

  Future<PickedImageData?> pick(ClearBgImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source == ClearBgImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 100,
    );

    if (file == null) {
      return null;
    }

    return PickedImageData(bytes: await file.readAsBytes(), name: file.name);
  }
}
