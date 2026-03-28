import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_background_remover/image_background_remover.dart';

class BackgroundRemovalService {
  // Slightly higher than the default to favor a cleaner foreground cutout.
  static const double tunedThreshold = 0.68;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await BackgroundRemover.instance.initializeOrt();
    _isInitialized = true;
  }

  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    await initialize();

    final ui.Image image = await BackgroundRemover.instance.removeBg(
      imageBytes,
      threshold: tunedThreshold,
      smoothMask: true,
      enhanceEdges: true,
    );

    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw StateError('Unable to convert the processed image to PNG bytes.');
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<Uint8List> applyBackgroundColor({
    required Uint8List transparentImageBytes,
    required Color color,
  }) async {
    // Reuse the transparent result and blend it over a solid color preview.
    final ui.Codec codec = await ui.instantiateImageCodec(
      transparentImageBytes,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image transparentImage = frame.image;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = color;
      final size = Size(
        transparentImage.width.toDouble(),
        transparentImage.height.toDouble(),
      );

      canvas.drawRect(Offset.zero & size, paint);
      canvas.drawImage(transparentImage, Offset.zero, Paint());

      final composedImage = await recorder.endRecording().toImage(
        transparentImage.width,
        transparentImage.height,
      );

      try {
        final ByteData? byteData = await composedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData == null) {
          throw StateError('Unable to apply the selected background color.');
        }

        return byteData.buffer.asUint8List();
      } finally {
        composedImage.dispose();
      }
    } finally {
      transparentImage.dispose();
      codec.dispose();
    }
  }

  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    await BackgroundRemover.instance.dispose();
    _isInitialized = false;
  }
}
