import 'dart:typed_data';

import 'platform_image_saver_stub.dart'
    if (dart.library.io) 'platform_image_saver_io.dart'
    as platform_saver;

class ImageSaveService {
  Future<String> savePng(Uint8List bytes, {required String fileName}) {
    return platform_saver.saveImage(bytes, fileName: fileName);
  }
}
