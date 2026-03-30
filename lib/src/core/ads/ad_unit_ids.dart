import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdUnitIds {
  static String get banner {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/9214589741';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2435281174';
      default:
        throw UnsupportedError(
          'Banner ads are only supported on Android and iOS.',
        );
    }
  }

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const AdRequest request = AdRequest();
}
