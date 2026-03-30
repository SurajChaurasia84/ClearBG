import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/core/ads/rewarded_ad_service.dart';
import 'src/data/services/background_removal_service.dart';
import 'src/data/services/image_picker_service.dart';
import 'src/data/services/image_save_service.dart';
import 'src/presentation/controllers/clearbg_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final backgroundRemovalService = BackgroundRemovalService();
  final controller = ClearBgController(
    backgroundService: backgroundRemovalService,
    imagePickerService: ImagePickerService(),
    imageSaveService: ImageSaveService(),
    rewardedAdService: RewardedAdService(),
  );

  runApp(ClearBgApp(controller: controller));

  unawaited(MobileAds.instance.initialize());
  unawaited(controller.warmUpEngine());
}
