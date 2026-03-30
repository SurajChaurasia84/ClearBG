import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/ads/rewarded_ad_service.dart';
import '../../data/services/background_removal_service.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/image_save_service.dart';

class ClearBgController extends ChangeNotifier {
  ClearBgController({
    required BackgroundRemovalService backgroundService,
    required ImagePickerService imagePickerService,
    required ImageSaveService imageSaveService,
    required RewardedAdService rewardedAdService,
    String? startupError,
  }) : _backgroundService = backgroundService,
       _imagePickerService = imagePickerService,
       _imageSaveService = imageSaveService,
       _rewardedAdService = rewardedAdService,
       _engineError = startupError;

  final BackgroundRemovalService _backgroundService;
  final ImagePickerService _imagePickerService;
  final ImageSaveService _imageSaveService;
  final RewardedAdService _rewardedAdService;

  Uint8List? _originalBytes;
  Uint8List? _transparentBytes;
  Uint8List? _previewBytes;
  String? _imageName;
  String? _errorMessage;
  String? _engineError;
  bool _isProcessing = false;
  bool _isSaving = false;
  String _busyMessage = 'Saving your image...';
  double _comparePosition = 0.5;
  Color? _selectedBackgroundColor;
  ClearBgImageSource? _lastSource;

  Uint8List? get originalBytes => _originalBytes;
  Uint8List? get previewBytes => _previewBytes;
  String? get errorMessage => _errorMessage;
  String? get engineError => _engineError;
  bool get isProcessing => _isProcessing;
  bool get isSaving => _isSaving;
  bool get hasResult => _previewBytes != null;
  double get comparePosition => _comparePosition;
  Color? get selectedBackgroundColor => _selectedBackgroundColor;
  bool get isReady => _backgroundService.isInitialized && _engineError == null;
  String get busyMessage => _busyMessage;

  Future<void> pickAndProcess(ClearBgImageSource source) async {
    _errorMessage = null;
    _lastSource = source;
    notifyListeners();

    try {
      await _ensureInitialized();
      final PickedImageData? picked = await _imagePickerService.pick(source);

      if (picked == null) {
        return;
      }

      _imageName = picked.name;
      _originalBytes = picked.bytes;
      _selectedBackgroundColor = null;
      _comparePosition = 0.5;
      _isProcessing = true;
      notifyListeners();

      final transparent = await _backgroundService.removeBackground(
        picked.bytes,
      );
      _transparentBytes = transparent;
      _previewBytes = transparent;
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    final lastSource = _lastSource;
    if (lastSource == null) {
      return;
    }

    await pickAndProcess(lastSource);
  }

  Future<void> selectBackgroundColor(Color? color) async {
    final transparent = _transparentBytes;
    if (transparent == null) {
      return;
    }

    _selectedBackgroundColor = color;
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _previewBytes = color == null
          ? transparent
          : await _backgroundService.applyBackgroundColor(
              transparentImageBytes: transparent,
              color: color,
            );
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String?> saveCurrentImage() async {
    final preview = _previewBytes;
    if (preview == null) {
      _errorMessage = 'Pick an image first so there is something to save.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _busyMessage = 'Saving with watermark...';
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await _backgroundService.addWatermark(imageBytes: preview);
      return await _imageSaveService.savePng(
        bytes,
        fileName: _buildFileName(isWatermarked: true),
      );
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
      return null;
    } finally {
      _isSaving = false;
      _busyMessage = 'Saving your image...';
      notifyListeners();
    }
  }

  Future<String?> watchAdAndSaveWithoutWatermark() async {
    final preview = _previewBytes;
    if (preview == null) {
      _errorMessage = 'Pick an image first so there is something to save.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _busyMessage = 'Loading rewarded ad...';
    _errorMessage = null;
    notifyListeners();

    try {
      final earnedReward = await _rewardedAdService.showRewardedSaveAd();
      if (!earnedReward) {
        _errorMessage =
            'Ad was not completed, so the clean save was cancelled.';
        return null;
      }

      _busyMessage = 'Saving without watermark...';
      notifyListeners();

      return await _imageSaveService.savePng(
        preview,
        fileName: _buildFileName(),
      );
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
      return null;
    } finally {
      _isSaving = false;
      _busyMessage = 'Saving your image...';
      notifyListeners();
    }
  }

  void updateComparePosition(double value) {
    _comparePosition = value.clamp(0.05, 0.95);
    notifyListeners();
  }

  Future<void> reinitializeEngine() async {
    _errorMessage = null;
    _engineError = null;
    _isProcessing = true;
    notifyListeners();

    try {
      await _backgroundService.initialize();
    } catch (error) {
      _engineError = _friendlyMessage(error);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> warmUpEngine() async {
    if (_backgroundService.isInitialized) {
      return;
    }

    try {
      await _backgroundService.initialize();
      if (_engineError != null) {
        _engineError = null;
        notifyListeners();
      }
    } catch (error) {
      _engineError = _friendlyMessage(error);
      notifyListeners();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_backgroundService.isInitialized) {
      return;
    }

    await reinitializeEngine();

    if (!_backgroundService.isInitialized) {
      throw StateError(
        _engineError ?? 'Background remover failed to initialize.',
      );
    }
  }

  String _buildFileName({bool isWatermarked = false}) {
    final String rawName = _imageName ?? 'clearbg_image';
    final String sanitizedName = rawName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final String suffix = _selectedBackgroundColor == null
        ? 'transparent'
        : 'colorized';
    final String watermarkSuffix = isWatermarked ? 'watermarked' : 'clean';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${sanitizedName}_${suffix}_${watermarkSuffix}_$timestamp.png';
  }

  String _friendlyMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('UnsupportedError')) {
      return 'Saving is not available on this platform yet.';
    }
    return message;
  }

  @override
  void dispose() {
    unawaited(_backgroundService.dispose());
    super.dispose();
  }
}
