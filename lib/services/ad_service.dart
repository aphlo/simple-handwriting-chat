import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'review_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // iOS Ad Unit IDs
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-6548153014267210/3660936921';
  static const String _iosNativeAdUnitId =
      'ca-app-pub-6548153014267210/7694700640';

  // Android Ad Unit IDs
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-6548153014267210/2347855252';
  static const String _androidNativeAdUnitId =
      'ca-app-pub-6548153014267210/5113619392';

  static const int _clearCountForInterstitial = 3;

  InterstitialAd? _interstitialAd;
  int _sessionClearCount = 0;
  bool _isInitialized = false;

  String get interstitialAdUnitId =>
      Platform.isIOS ? _iosInterstitialAdUnitId : _androidInterstitialAdUnitId;

  String get nativeAdUnitId =>
      Platform.isIOS ? _iosNativeAdUnitId : _androidNativeAdUnitId;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _loadInterstitialAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('Interstitial ad failed to show: $error');
                  ad.dispose();
                  _loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> onClearButtonPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewRequested =
        prefs.getBool(ReviewService.reviewRequestedKey) ?? false;

    // Only count and show interstitial if review has been requested
    if (!reviewRequested) {
      return;
    }

    _sessionClearCount++;

    if (_sessionClearCount >= _clearCountForInterstitial) {
      _sessionClearCount = 0;
      await _showInterstitialAd();
    }
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  NativeAd createNativeAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );
  }
}
