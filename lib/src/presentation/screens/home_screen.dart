import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/image_picker_service.dart';
import '../controllers/clearbg_controller.dart';
import 'premium_screen.dart';
import '../widgets/bottom_banner_ad.dart';
import '../widgets/glass_panel.dart';
import '../widgets/preview_compare_slider.dart';
import '../widgets/primary_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final ClearBgController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const List<Color> _backgroundOptions = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFF8E9D2),
    Color(0xFFDFF7F5),
    Color(0xFF419CD5),
    Color(0xFF111827),
    Color(0xFFFFD6E7),
    Color(0xFFFFF1A8),
    Color(0xFFCDEB8B),
  ];

  late final AnimationController _watchAdPulseController;
  late final Animation<double> _watchAdScaleAnimation;

  @override
  void initState() {
    super.initState();
    _watchAdPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _watchAdScaleAnimation = Tween<double>(begin: 1, end: 1.04).animate(
      CurvedAnimation(parent: _watchAdPulseController, curve: Curves.easeInOut),
    );
    widget.controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    _watchAdPulseController.dispose();
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
            bottomNavigationBar: const BottomBannerAd(),
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
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            MediaQuery.of(context).padding.top + 12,
                            20,
                            0,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 10,
                              ),
                              child: _buildFixedAppBar(context),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  18,
                                  20,
                                  20,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
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
                      ],
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
                                      ? widget.controller.busyMessage
                                      : 'Removing background...',
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
        // Text(
        //   'Offline AI background removal with privacy-first ONNX processing.',
        //   textAlign: TextAlign.center,
        //   style: Theme.of(
        //     context,
        //   ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        // ),
        const SizedBox(height: 28),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            children: [
              const TextSpan(text: 'Pick a photo and get a clean '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GradientText(
                  'Transparent',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              const TextSpan(text: ' cutout in seconds.'),
            ],
          ),
        ),
        const SizedBox(height: 38),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: PrimaryActionButton(
                icon: Icons.photo_camera_outlined,
                label: 'Use Camera',
                onPressed: () =>
                    widget.controller.pickAndProcess(ClearBgImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: PrimaryActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Use Gallery',
                onPressed: () => widget.controller.pickAndProcess(
                  ClearBgImageSource.gallery,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFixedAppBar(BuildContext context) {
    return Row(
      children: [
        Text(
          'ClearBG',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _openPremium(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/premium.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'Premium',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPremium(BuildContext context) async {
    await Navigator.of(context).push(_buildPremiumRoute());
  }

  Route<void> _buildPremiumRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PremiumScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
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
            const Spacer(),
            Text(
              widget.controller.selectedBackgroundColor == null
                  ? 'After • Transparent PNG'
                  : 'After • Color Preview',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
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
        Align(
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _watchAdScaleAnimation,
            child: FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final savedMessage = await widget.controller
                    .watchAdAndSaveWithoutWatermark();
                if (!mounted || savedMessage == null) {
                  return;
                }
                messenger.showSnackBar(SnackBar(content: Text(savedMessage)));
              },
              icon: const Icon(Icons.ondemand_video_rounded),
              label: const Text('Watch Ad to Remove Watermark'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final bool hasImage = widget.controller.hasResult;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
          FilledButton.icon(
            onPressed: hasImage
                ? () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final savedMessage = await widget.controller
                        .saveCurrentImage();
                    if (!mounted || savedMessage == null) {
                      return;
                    }
                    messenger.showSnackBar(
                      SnackBar(content: Text(savedMessage)),
                    );
                  }
                : null,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPicker(BuildContext context) {
    final bool hasImage = widget.controller.hasResult;
    final List<Widget> swatches = [
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
      _ColorSwatchButton(
        icon: Icons.colorize_rounded,
        isGradientPreview: true,
        isSelected:
            hasImage &&
            widget.controller.selectedBackgroundColor != null &&
            !_backgroundOptions.contains(
              widget.controller.selectedBackgroundColor,
            ),
        onTap: hasImage ? () => _showCustomColorPicker(context) : null,
      ),
    ];

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
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final itemWidth = (constraints.maxWidth - (spacing * 3)) / 4;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final swatch in swatches)
                  SizedBox(width: itemWidth, child: swatch),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showCustomColorPicker(BuildContext context) async {
    Color pickerColor =
        widget.controller.selectedBackgroundColor ?? const Color(0xFF419CD5);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101A28),
          title: const Text('Pick Background Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              enableAlpha: false,
              labelTypes: const [],
              portraitOnly: true,
              pickerAreaHeightPercent: 0.75,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                widget.controller.selectBackgroundColor(pickerColor);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
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

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    this.color,
    required this.isSelected,
    required this.onTap,
    this.label,
    this.icon,
    this.isGradientPreview = false,
  });

  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? label;
  final IconData? icon;
  final bool isGradientPreview;

  @override
  Widget build(BuildContext context) {
    final bool useDarkIcon = color == null || color!.computeLuminance() > 0.6;
    final Color fallbackColor = color ?? Colors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: isGradientPreview
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8A65),
                    Color(0xFFFDE68A),
                    Color(0xFF67E8F9),
                    Color(0xFF60A5FA),
                    Color(0xFFC084FC),
                  ],
                )
              : null,
          color: isGradientPreview ? null : fallbackColor,
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
                  isSelected
                      ? Icons.check_rounded
                      : (icon ?? Icons.palette_outlined),
                  color: isGradientPreview
                      ? Colors.white
                      : (useDarkIcon ? Colors.black87 : Colors.white),
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

class GradientText extends StatelessWidget {
  const GradientText(this.text, {required this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF67E8F9)],
        ).createShader(bounds);
      },
      child: Text(text, style: style),
    );
  }
}
