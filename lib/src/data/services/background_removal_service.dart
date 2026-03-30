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

  Future<Uint8List> addWatermark({
    required Uint8List imageBytes,
    String text = 'ClearBG',
  }) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image baseImage = frame.image;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(
        baseImage.width.toDouble(),
        baseImage.height.toDouble(),
      );

      canvas.drawImage(baseImage, Offset.zero, Paint());

      final double fontSize = (size.shortestSide * 0.055).clamp(18.0, 34.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: const Color(0xEFFFFFFF),
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double horizontalPadding = fontSize * 0.55;
      final double verticalPadding = fontSize * 0.34;
      final double margin = fontSize * 0.8;
      final Offset textOffset = Offset(
        size.width - textPainter.width - horizontalPadding - margin,
        size.height - textPainter.height - verticalPadding - margin,
      );

      textPainter.paint(canvas, textOffset);

      final ui.Image watermarkedImage = await recorder.endRecording().toImage(
        baseImage.width,
        baseImage.height,
      );

      try {
        final ByteData? byteData = await watermarkedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData == null) {
          throw StateError('Unable to add the watermark to this image.');
        }

        return byteData.buffer.asUint8List();
      } finally {
        watermarkedImage.dispose();
      }
    } finally {
      baseImage.dispose();
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
