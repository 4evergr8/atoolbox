import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:picorigin/string.dart';
import 'package:picorigin/widget.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();

  factory AdManager() {
    return instance;
  }

  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  VoidCallback? _pendingAction;

  int _adStateIndex = 0;

  bool get _canShowAd {
    return DateTime.now().isAfter(DateTime(2026, 8, 18));
  }

  void loadInterstitialAd() {
    if (!_canShowAd) {
      return;
    }

    if (_isAdReady || _interstitialAd != null) {
      return;
    }

    InterstitialAd.load(
      adUnitId: adid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;

              _pendingAction?.call();
              _pendingAction = null;

              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitialAd = null;
              _isAdReady = false;

              _pendingAction?.call();
              _pendingAction = null;

              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (e) {
          _isAdReady = false;
          _interstitialAd = null;
          //showSnackBarGlobal('error', '$e');

          if (e.code != 3) {
            Future.delayed(const Duration(seconds: 10), () {
              loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  void showAdThen(VoidCallback action) {
    _adStateIndex++;

    if (_canShowAd && _adStateIndex % 3 == 1 && _isAdReady && _interstitialAd != null) {
      _pendingAction = action;
      _interstitialAd!.show();
    } else {
      action();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
