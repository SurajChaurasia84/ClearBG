import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/data/services/background_removal_service.dart';
import 'src/data/services/image_picker_service.dart';
import 'src/data/services/image_save_service.dart';
import 'src/presentation/controllers/clearbg_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Warm up the ONNX runtime once so the first edit feels instant.
  final backgroundRemovalService = BackgroundRemovalService();
  String? startupError;

  try {
    await backgroundRemovalService.initialize();
  } catch (error) {
    startupError = error.toString();
  }

  final controller = ClearBgController(
    backgroundService: backgroundRemovalService,
    imagePickerService: ImagePickerService(),
    imageSaveService: ImageSaveService(),
    startupError: startupError,
  );

  runApp(ClearBgApp(controller: controller));
}
