import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/image_picker_service.dart';
import '../controllers/clearbg_controller.dart';
import '../widgets/glass_panel.dart';
import '../widgets/preview_compare_slider.dart';
import '../widgets/primary_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final ClearBgController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Color> _backgroundOptions = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFF8E9D2),
    Color(0xFFDFF7F5),
    Color(0xFF111827),
    Color(0xFFFFD6E7),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerUpdate);
    widget.controller.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    final message = widget.controller.errorMessage;
    if (message == null || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action:
              widget.controller.hasResult ||
                  widget.controller.engineError != null
              ? SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    if (widget.controller.engineError != null) {
                      widget.controller.reinitializeEngine();
                      return;
                    }
                    widget.controller.retry();
                  },
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0x00000000),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Color(0x00000000),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppTheme.start, AppTheme.end],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: _AmbientBackgroundPainter()),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            MediaQuery.of(context).padding.top + 20,
                            20,
                            20,
                          ),
                          child: Column(
                            children: [
                              GlassPanel(
                                padding: const EdgeInsets.all(24),
                                child: _buildHeader(context),
                              ),
                              const SizedBox(height: 18),
                              GlassPanel(
                                padding: const EdgeInsets.all(16),
                                child: _buildPreviewArea(context),
                              ),
                              const SizedBox(height: 18),
                              _buildActions(),
                              const SizedBox(height: 18),
                              GlassPanel(
                                padding: const EdgeInsets.all(18),
                                child: _buildBackgroundPicker(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.controller.isProcessing ||
                      widget.controller.isSaving)
                    Positioned.fill(
                      child: ColoredBox(
                        color: const Color(0x6608141F),
                        child: Center(
                          child: GlassPanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.controller.isSaving
                                      ? 'Saving your PNG...'
                                      : 'Removing background offline...',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'ClearBG',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          'Offline AI background removal with privacy-first ONNX processing.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            PrimaryActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Pick From Gallery',
              onPressed: () =>
                  widget.controller.pickAndProcess(ClearBgImageSource.gallery),
            ),
            PrimaryActionButton(
              icon: Icons.photo_camera_outlined,
              label: 'Use Camera',
              onPressed: () =>
                  widget.controller.pickAndProcess(ClearBgImageSource.camera),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewArea(BuildContext context) {
    final Uint8List? original = widget.controller.originalBytes;
    final Uint8List? preview = widget.controller.previewBytes;

    if (!widget.controller.isReady && widget.controller.engineError != null) {
      return _StatusState(
        title: 'Model initialization needs attention',
        subtitle: widget.controller.engineError!,
        actionLabel: 'Retry Initialization',
        onPressed: widget.controller.reinitializeEngine,
      );
    }

    if (original == null || preview == null) {
      return const _StatusState(
        title: 'Drop in a photo to start',
        subtitle:
            'Choose an image from the gallery or camera, then ClearBG will remove the background locally on your device.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _LabelChip(
              label: 'Before',
              color: Colors.white.withValues(alpha: 0.16),
            ),
            const Spacer(),
            _LabelChip(
              label: widget.controller.selectedBackgroundColor == null
                  ? 'After • Transparent PNG'
                  : 'After • Color Preview',
              color: const Color(0x401BCEDF),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 1,
            child: PreviewCompareSlider(
              originalBytes: original,
              processedBytes: preview,
              value: widget.controller.comparePosition,
              onChanged: widget.controller.updateComparePosition,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: widget.controller.comparePosition,
                  onChanged: widget.controller.updateComparePosition,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final savedMessage = await widget.controller.saveCurrentImage();
                if (!mounted || savedMessage == null) {
                  return;
                }
                messenger.showSnackBar(SnackBar(content: Text(savedMessage)));
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Save PNG'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    final bool hasImage = widget.controller.hasResult;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: hasImage ? widget.controller.retry : null,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
          OutlinedButton.icon(
            onPressed: hasImage
                ? () => widget.controller.selectBackgroundColor(null)
                : null,
            icon: const Icon(Icons.layers_clear_outlined),
            label: const Text('Transparent'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPicker(BuildContext context) {
    final bool hasImage = widget.controller.hasResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Color',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Keep it transparent or preview the cutout on a custom color before saving.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ColorSwatchButton(
              label: 'None',
              isSelected: widget.controller.selectedBackgroundColor == null,
              onTap: hasImage
                  ? () => widget.controller.selectBackgroundColor(null)
                  : null,
            ),
            for (final color in _backgroundOptions)
              _ColorSwatchButton(
                color: color,
                isSelected: widget.controller.selectedBackgroundColor == color,
                onTap: hasImage
                    ? () => widget.controller.selectBackgroundColor(color)
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusState extends StatelessWidget {
  const _StatusState({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(label),
    );
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    this.color,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bool useDarkIcon = color == null || color!.computeLuminance() > 0.6;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            width: isSelected ? 3 : 1,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    color: useDarkIcon ? Colors.white : Colors.black,
                  ),
                )
              : Icon(
                  isSelected ? Icons.check_rounded : Icons.palette_outlined,
                  color: useDarkIcon ? Colors.black87 : Colors.white,
                ),
        ),
      ),
    );
  }
}

class _AmbientBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.12),
              radius: size.width * 0.32,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      size.width * 0.32,
      paint,
    );

    final Paint secondary = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x40111B2F), Color(0x00111B2F)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.16, size.height * 0.82),
              radius: size.width * 0.30,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.82),
      size.width * 0.30,
      secondary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
