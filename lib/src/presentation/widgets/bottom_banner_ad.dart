import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/ads/ad_unit_ids.dart';

class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  static const Duration _refreshInterval = Duration(seconds: 90);

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startBannerCycle();
    });
  }

  void _startBannerCycle() {
    _loadBanner();
    _refreshTimer ??= Timer.periodic(_refreshInterval, (_) {
      _refreshBanner();
    });
  }

  Future<void> _refreshBanner() async {
    _bannerAd?.dispose();

    if (!mounted) {
      return;
    }

    setState(() {
      _bannerAd = null;
      _isLoaded = false;
    });

    await _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (!AdUnitIds.isSupported) {
      return;
    }

    final ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      request: AdUnitIds.request,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFF0E1624),
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
