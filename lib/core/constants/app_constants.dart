/// App-wide constants for the mining game
class AppConstants {
  AppConstants._();

  // Coin conversion
  static const int coinsPerINR = 10000; // 10,000 coins = ₹1
  static const int minWithdrawalCoins = 500000; // ₹50
  static const int processingFeeCoins = 100000; // ₹10

  // Tap limits
  static const int tapsPerClaim = 100; // Watch ad every 100 taps
  static const int dailyTapCap = 1000000000; // Unlimited
  static const int maxTapsPerSecond = 20; // Increased
  static const int flagTapsPerSecond = 30; // Increased

  // Passive mining
  static const double freePassiveRate = 0.1; // coins per second
  static const int freeOfflineHours = 2;
  static const int freeDailyPassiveCap = 10000;

  static const double premiumPassiveRate = 0.5; // coins per second
  static const int premiumOfflineHours = 6;
  static const int premiumDailyPassiveCap = 50000;

  // Base tap power
  static const int baseTapPower = 1;

  // Daily bonus amounts
  static const Map<int, int> dailyBonusAmounts = {
    1: 500,
    2: 500,
    3: 500,
    4: 500,
    5: 500,
    6: 500,
    7: 5000,
    14: 10000,
    30: 50000,
    60: 100000,
    90: 200000,
  };

  // Referral
  static const int maxReferrals = 10;
  static const int refereeBonus = 5000; // New user gets this
  static const int referrerBonus =
      20000; // Referrer gets this when referee earns 10K
  static const int referralReward = 20000; // Reward for valid referral
  static const int referralActiveThreshold = 10000; // Referee must earn this

  // Withdrawal limits
  static const int minWithdrawalINR = 50;
  static const int maxWithdrawalINR = 5000;
  static const int withdrawalsPerWeek = 1;
  static const int processingDays = 5;

  // Ad settings
  static const int interstitialCooldown = 180; // 3 minutes in seconds
  static const int maxInterstitialsPerDay = 15;
  static const int appOpenAdCooldown = 14400; // 4 hours in seconds

  // Session settings
  static const int tapSyncInterval = 5; // seconds between tap syncs
  static const int maxSessionHours = 12;

  // Animation durations (milliseconds)
  static const int shortAnimation = 200;
  static const int mediumAnimation = 300;
  static const int longAnimation = 500;

  // Upgrade level settings
  static const int maxUpgradeLevel = 50;
  static const double upgradeCostMultiplier = 1.15; // 15% increase per level
  static const double upgradeEffectMultiplier = 1.10; // 10% increase per level

  // Achievement coin rewards
  static const int tutorialCompletionBonus = 5000;

  // API Endpoints (to be configured)
  static const String cloudflareWorkerBaseUrl =
      'https://cryptominer-worker.earnplay12345.workers.dev';
}

/// Upgrade tier data
class UpgradeTiers {
  UpgradeTiers._();

  // Tap Power Upgrades
  static const List<Map<String, dynamic>> tapUpgrades = [
    {
      'id': 'tap_1',
      'name': 'Basic GPU',
      'cost': 5000,
      'effect': 0.2,
      'icon': '🖥️',
    },
    {
      'id': 'tap_2',
      'name': 'Dual GPU',
      'cost': 25000,
      'effect': 1.0,
      'icon': '💻',
    },
    {
      'id': 'tap_3',
      'name': 'GPU Rig',
      'cost': 100000,
      'effect': 5.0,
      'icon': '🎮',
    },
    {
      'id': 'tap_4',
      'name': 'ASIC Miner',
      'cost': 500000,
      'effect': 25.0,
      'icon': '⚡',
    },
    {
      'id': 'tap_5',
      'name': 'Mining Farm',
      'cost': 2000000,
      'effect': 100.0,
      'icon': '🏭',
    },
    {
      'id': 'tap_6',
      'name': 'Data Center',
      'cost': 10000000,
      'effect': 500.0,
      'icon': '🏢',
    },
    {
      'id': 'tap_7',
      'name': 'Server Network',
      'cost': 50000000,
      'effect': 2500.0,
      'icon': '🌐',
    },
    {
      'id': 'tap_8',
      'name': 'Quantum Rig',
      'cost': 250000000,
      'effect': 10000.0,
      'icon': '🔮',
    },
  ];

  // Passive Rate Upgrades
  static const List<Map<String, dynamic>> passiveUpgrades = [
    {
      'id': 'passive_1',
      'name': 'CPU Miner',
      'cost': 8000,
      'effect': 0.1,
      'icon': '🔧',
    },
    {
      'id': 'passive_2',
      'name': 'Old GPU',
      'cost': 40000,
      'effect': 0.5,
      'icon': '📟',
    },
    {
      'id': 'passive_3',
      'name': 'Modern GPU',
      'cost': 150000,
      'effect': 2.0,
      'icon': '📊',
    },
    {
      'id': 'passive_4',
      'name': 'ASIC Passive',
      'cost': 750000,
      'effect': 10.0,
      'icon': '🔋',
    },
    {
      'id': 'passive_5',
      'name': 'Auto Farm',
      'cost': 3000000,
      'effect': 50.0,
      'icon': '🤖',
    },
    {
      'id': 'passive_6',
      'name': 'Smart Grid',
      'cost': 15000000,
      'effect': 250.0,
      'icon': '📡',
    },
    {
      'id': 'passive_7',
      'name': 'AI Optimizer',
      'cost': 75000000,
      'effect': 1250.0,
      'icon': '🧠',
    },
    {
      'id': 'passive_8',
      'name': 'Neural Net',
      'cost': 400000000,
      'effect': 6000.0,
      'icon': '🚀',
    },
  ];

  // Cooling Upgrades (Thermal Throttling)
  static const List<Map<String, dynamic>> coolingUpgrades = [
    {
      'id': 'fan_1',
      'name': 'Basic Fan',
      'cost': 1500,
      'effect': 1.0, // +1 cooling/sec
      'icon': '🌬️',
    },
    {
      'id': 'sink_1',
      'name': 'Heat Sink',
      'cost': 5000,
      'effect': 2.0,
      'icon': '❄️',
    },
    {
      'id': 'liquid_1',
      'name': 'Liquid Cooling',
      'cost': 15000,
      'effect': 5.0,
      'icon': '💧',
    },
    {
      'id': 'nitrogen_1',
      'name': 'Nitrogen Loop',
      'cost': 50000,
      'effect': 10.0,
      'icon': '🧪',
    },
  ];
}

/// Achievement definitions
class AchievementDefinitions {
  AchievementDefinitions._();

  static const List<Map<String, dynamic>> achievements = [
    // Getting Started
    {
      'id': 'first_tap',
      'name': 'First Tap',
      'desc': 'Tap once',
      'reward': 500,
      'category': 'getting_started',
    },
    {
      'id': 'century',
      'name': 'Century',
      'desc': 'Tap 100 times',
      'reward': 1000,
      'category': 'getting_started',
    },
    {
      'id': 'first_upgrade',
      'name': 'First Upgrade',
      'desc': 'Purchase any upgrade',
      'reward': 1500,
      'category': 'getting_started',
    },
    {
      'id': 'first_claim',
      'name': 'First Claim',
      'desc': 'Claim passive earnings',
      'reward': 1000,
      'category': 'getting_started',
    },
    {
      'id': 'week_warrior',
      'name': 'Week Warrior',
      'desc': '7-day login streak',
      'reward': 2000,
      'category': 'getting_started',
    },

    // Tap Master
    {
      'id': '1k_taps',
      'name': '1K Taps',
      'desc': '1,000 total taps',
      'reward': 2000,
      'category': 'tap_master',
    },
    {
      'id': '10k_taps',
      'name': '10K Taps',
      'desc': '10,000 total taps',
      'reward': 5000,
      'category': 'tap_master',
    },
    {
      'id': '50k_taps',
      'name': '50K Taps',
      'desc': '50,000 total taps',
      'reward': 8000,
      'category': 'tap_master',
    },
    {
      'id': 'speed_demon',
      'name': 'Speed Demon',
      'desc': '50 taps in 10 seconds',
      'reward': 3000,
      'category': 'tap_master',
    },
    {
      'id': 'tap_god',
      'name': 'Tap God',
      'desc': '100,000 total taps',
      'reward': 7000,
      'category': 'tap_master',
    },

    // Passive Income
    {
      'id': 'passive_starter',
      'name': 'Passive Starter',
      'desc': 'Earn 10K coins passively',
      'reward': 3000,
      'category': 'passive',
    },
    {
      'id': 'passive_pro',
      'name': 'Passive Pro',
      'desc': 'Earn 100K coins passively',
      'reward': 7000,
      'category': 'passive',
    },
    {
      'id': 'overnight_earner',
      'name': 'Overnight Earner',
      'desc': 'Claim 6-hour passive',
      'reward': 5000,
      'category': 'passive',
    },

    // Wealth Builder
    {
      'id': '100k_club',
      'name': '100K Club',
      'desc': 'Earn 100K total coins',
      'reward': 5000,
      'category': 'wealth',
    },
    {
      'id': 'millionaire',
      'name': 'Millionaire',
      'desc': 'Earn 1M total coins',
      'reward': 10000,
      'category': 'wealth',
    },
    {
      'id': 'big_spender',
      'name': 'Big Spender',
      'desc': 'Spend 50K on upgrades',
      'reward': 3000,
      'category': 'wealth',
    },
    {
      'id': 'investor',
      'name': 'Investor',
      'desc': 'Own 5 different upgrades',
      'reward': 2000,
      'category': 'wealth',
    },

    // Social
    {
      'id': 'friend_finder',
      'name': 'Friend Finder',
      'desc': 'Refer 1 active user',
      'reward': 2000,
      'category': 'social',
    },
    {
      'id': 'influencer',
      'name': 'Influencer',
      'desc': 'Refer 5 active users',
      'reward': 5000,
      'category': 'social',
    },
    {
      'id': 'ambassador',
      'name': 'Ambassador',
      'desc': 'Refer 10 active users',
      'reward': 7000,
      'category': 'social',
    },
  ];
}

/// IAP Product IDs
class IAPProducts {
  IAPProducts._();

  static const String removeAds = 'remove_ads_forever';
  static const String boost2x7days = 'boost_2x_7days';
  static const String boost5x7days = 'boost_5x_7days';
  static const String starterPack = 'starter_pack';
  static const String growthPack = 'growth_pack';
  static const String vipMonthly = 'vip_monthly';
  static const String passiveBooster = 'passive_booster';

  static const Map<String, Map<String, dynamic>> products = {
    removeAds: {
      'name': 'Remove Ads Forever',
      'priceINR': 299,
      'type': 'one_time',
    },
    boost2x7days: {
      'name': '2x Boost (7 days)',
      'priceINR': 99,
      'type': 'one_time',
    },
    boost5x7days: {
      'name': '5x Boost (7 days)',
      'priceINR': 199,
      'type': 'one_time',
    },
    starterPack: {
      'name': 'Starter Pack',
      'priceINR': 149,
      'coins': 500000,
      'type': 'one_time',
    },
    growthPack: {
      'name': 'Growth Pack',
      'priceINR': 349,
      'coins': 2000000,
      'type': 'one_time',
    },
    vipMonthly: {
      'name': 'VIP Monthly',
      'priceINR': 199,
      'type': 'subscription',
    },
    passiveBooster: {
      'name': 'Passive Manager',
      'priceINR': 149,
      'type': 'one_time',
    },
  };
}

/// AdMob Ad Unit IDs (replace with real IDs)
class AdMobIds {
  AdMobIds._();

  // Test IDs (replace with production IDs)// already replaced with productions IDs
  static const String bannerAdUnitId = 'ca-app-pub-3863562453957252/4000539271';
  static const String interstitialAdUnitId =
      'ca-app-pub-3863562453957252/3669366780';
  static const String rewardedAdUnitId =
      'ca-app-pub-3863562453957252/2356285112';
  static const String appOpenAdUnitId =
      'ca-app-pub-3863562453957252/7316428755';
  static const String nativeAdUnitId = 'ca-app-pub-3863562453957252/6003347084';
}
