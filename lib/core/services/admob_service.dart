import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

/// Service for AdMob ads management
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  // Loading states
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  bool _isAppOpenLoaded = false;

  // Tracking
  DateTime? _lastInterstitialTime;
  DateTime? _lastAppOpenTime;
  int _interstitialCountToday = 0;
  DateTime? _lastInterstitialCountReset;

  // Whether ads are removed (user purchased)
  bool _adsRemoved = false;

  /// Initialize the AdMob SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized');
  }

  /// Set ads removed status
  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      disposeBanner();
      disposeInterstitial();
      disposeAppOpen();
    }
  }

  // ===== BANNER AD =====

  /// Load banner ad
  Future<void> loadBanner({
    required Function(Ad) onLoaded,
    required Function(Ad, LoadAdError) onFailed,
  }) async {
    if (_adsRemoved) return;

    _bannerAd = BannerAd(
      adUnitId: AdMobIds.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          onLoaded(ad);
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
          onFailed(ad, error);
          debugPrint('Banner ad failed to load: ${error.message}');
        },
        onAdClicked: (ad) {
          debugPrint('Banner ad clicked');
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Get banner ad widget
  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;

  /// Is banner loaded
  bool get isBannerLoaded => _isBannerLoaded && !_adsRemoved;

  /// Dispose banner
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ===== INTERSTITIAL AD =====

  /// Load interstitial ad
  Future<void> loadInterstitial() async {
    if (_adsRemoved) return;

    await InterstitialAd.load(
      adUnitId: AdMobIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          debugPrint('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Check if interstitial can be shown
  bool get canShowInterstitial {
    if (_adsRemoved) return false;
    if (!_isInterstitialLoaded || _interstitialAd == null) return false;

    // Check cooldown (3 minutes)
    if (_lastInterstitialTime != null) {
      final elapsed = DateTime.now()
          .difference(_lastInterstitialTime!)
          .inSeconds;
      if (elapsed < AppConstants.interstitialCooldown) return false;
    }

    // Check daily limit
    _resetDailyCountIfNeeded();
    if (_interstitialCountToday >= AppConstants.maxInterstitialsPerDay) {
      return false;
    }

    return true;
  }

  /// Show interstitial ad
  Future<bool> showInterstitial({
    required Function() onDismissed,
    Function()? onFailed,
  }) async {
    if (!canShowInterstitial) {
      onFailed?.call();
      return false;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        _lastInterstitialTime = DateTime.now();
        _interstitialCountToday++;
        onDismissed();
        loadInterstitial(); // Preload next
        debugPrint('Interstitial ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        onFailed?.call();
        loadInterstitial();
        debugPrint('Interstitial ad failed to show: ${error.message}');
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  /// Dispose interstitial
  void disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }

  // ===== REWARDED AD =====

  /// Load rewarded ad
  Future<void> loadRewarded() async {
    await RewardedAd.load(
      adUnitId: AdMobIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          debugPrint('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Is rewarded ad ready
  bool get isRewardedReady => _isRewardedLoaded && _rewardedAd != null;

  /// Show rewarded ad
  Future<bool> showRewarded({
    required Function(int amount) onRewarded,
    required Function() onDismissed,
    Function()? onFailed,
  }) async {
    if (!isRewardedReady) {
      onFailed?.call();
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        onDismissed();
        loadRewarded(); // Preload next
        debugPrint('Rewarded ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        onFailed?.call();
        loadRewarded();
        debugPrint('Rewarded ad failed to show: ${error.message}');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward.amount.toInt());
        debugPrint('Rewarded ad: earned ${reward.amount} ${reward.type}');
      },
    );

    return true;
  }

  /// Dispose rewarded
  void disposeRewarded() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedLoaded = false;
  }

  // ===== APP OPEN AD =====

  /// Load app open ad
  Future<void> loadAppOpen() async {
    if (_adsRemoved) return;

    await AppOpenAd.load(
      adUnitId: AdMobIds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoaded = true;
          debugPrint('App open ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoaded = false;
          debugPrint('App open ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Check if app open ad can be shown
  bool get canShowAppOpen {
    if (_adsRemoved) return false;
    if (!_isAppOpenLoaded || _appOpenAd == null) return false;

    // Check cooldown (4 hours)
    if (_lastAppOpenTime != null) {
      final elapsed = DateTime.now().difference(_lastAppOpenTime!).inSeconds;
      if (elapsed < AppConstants.appOpenAdCooldown) return false;
    }

    return true;
  }

  /// Show app open ad
  Future<bool> showAppOpen({
    required Function() onDismissed,
    Function()? onFailed,
  }) async {
    if (!canShowAppOpen) {
      onFailed?.call();
      return false;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenLoaded = false;
        _lastAppOpenTime = DateTime.now();
        onDismissed();
        loadAppOpen(); // Preload next
        debugPrint('App open ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenLoaded = false;
        onFailed?.call();
        loadAppOpen();
        debugPrint('App open ad failed to show: ${error.message}');
      },
    );

    await _appOpenAd!.show();
    return true;
  }

  /// Dispose app open
  void disposeAppOpen() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenLoaded = false;
  }

  // ===== HELPERS =====

  /// Reset daily interstitial count if needed
  void _resetDailyCountIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastInterstitialCountReset == null ||
        _lastInterstitialCountReset!.isBefore(today)) {
      _interstitialCountToday = 0;
      _lastInterstitialCountReset = today;
    }
  }

  /// Preload all ads
  Future<void> preloadAds() async {
    await Future.wait([loadInterstitial(), loadRewarded(), loadAppOpen()]);
  }

  /// Dispose all ads
  void disposeAll() {
    disposeBanner();
    disposeInterstitial();
    disposeRewarded();
    disposeAppOpen();
  }
}
