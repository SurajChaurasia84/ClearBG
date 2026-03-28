import 'dart:typed_data';

import 'package:flutter/material.dart';

class PreviewCompareSlider extends StatelessWidget {
  const PreviewCompareSlider({
    required this.originalBytes,
    required this.processedBytes,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final revealWidth = width * value;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final localPosition = (details.localPosition.dx / width).clamp(
              0.0,
              1.0,
            );
            onChanged(localPosition);
          },
          onTapDown: (details) {
            final localPosition = (details.localPosition.dx / width).clamp(
              0.0,
              1.0,
            );
            onChanged(localPosition);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PreviewImage(bytes: originalBytes),
              // Reveal only part of the processed image so the handle can scrub.
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: SizedBox(
                    width: width,
                    child: _PreviewImage(bytes: processedBytes),
                  ),
                ),
              ),
              Positioned(
                left: revealWidth - 1.5,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: Colors.white),
              ),
              Positioned(
                left: revealWidth - 22,
                top: constraints.maxHeight / 2 - 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F6FA), Color(0xFFE2E8F0)],
        ),
      ),
      child: Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true),
    );
  }
}
