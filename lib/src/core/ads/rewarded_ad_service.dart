import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

class RewardedAdService {
  Future<bool> showRewardedSaveAd() async {
    if (!AdUnitIds.isSupported) {
      throw UnsupportedError('Rewarded ads are only supported on mobile.');
    }

    final Completer<RewardedAd> loadCompleter = Completer<RewardedAd>();

    await RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: AdUnitIds.request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loadCompleter.complete,
        onAdFailedToLoad: (error) {
          loadCompleter.completeError(
            StateError('Rewarded ad failed to load: $error'),
          );
        },
      ),
    );

    final RewardedAd ad = await loadCompleter.future;
    final Completer<bool> resultCompleter = Completer<bool>();
    bool didEarnReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(didEarnReward);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!resultCompleter.isCompleted) {
          resultCompleter.completeError(
            StateError('Rewarded ad failed to show: $error'),
          );
        }
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        didEarnReward = true;
      },
    );

    return resultCompleter.future;
  }
}
