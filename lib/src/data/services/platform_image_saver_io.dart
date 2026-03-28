import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveImage(Uint8List bytes, {required String fileName}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Gal.putImageBytes(bytes, album: 'ClearBG');
    return 'Image saved to your gallery.';
  }

  final Directory targetDirectory =
      await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final String filePath =
      '${targetDirectory.path}${Platform.pathSeparator}$fileName';
  final File file = File(filePath);

  await file.writeAsBytes(bytes, flush: true);
  return 'Image saved to $filePath';
}
