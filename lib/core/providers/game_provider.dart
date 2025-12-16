import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/upgrade_model.dart';
import '../models/achievement_model.dart';
import '../services/game_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

// ===== SERVICE PROVIDERS =====

final gameServiceProvider = Provider((ref) => GameService());
final firestoreServiceProvider = Provider((ref) => FirestoreService());
final authServiceProvider = Provider((ref) => AuthService());
final apiServiceProvider = Provider((ref) => ApiService());

// ===== GAME STATE NOTIFIER =====

class GameState {
  final UserModel? user;
  final List<UpgradeModel> upgrades;
  final List<AchievementModel> achievements;
  final List<OwnedUpgrade> ownedUpgrades;
  final int pendingTaps;
  final int pendingCoins;
  final bool isLoading;
  final String? error;
  final PassiveEarnings? pendingPassive;
  final AchievementModel? newlyUnlockedAchievement;

  const GameState({
    this.user,
    this.upgrades = const [],
    this.achievements = const [],
    this.ownedUpgrades = const [],
    this.pendingTaps = 0,
    this.pendingCoins = 0,
    this.isLoading = false,
    this.error,
    this.pendingPassive,
    this.newlyUnlockedAchievement,
  });

  GameState copyWith({
    UserModel? user,
    List<UpgradeModel>? upgrades,
    List<AchievementModel>? achievements,
    List<OwnedUpgrade>? ownedUpgrades,
    int? pendingTaps,
    int? pendingCoins,
    bool? isLoading,
    String? error,
    PassiveEarnings? pendingPassive,
    AchievementModel? newlyUnlockedAchievement,
  }) {
    return GameState(
      user: user ?? this.user,
      upgrades: upgrades ?? this.upgrades,
      achievements: achievements ?? this.achievements,
      ownedUpgrades: ownedUpgrades ?? this.ownedUpgrades,
      pendingTaps: pendingTaps ?? this.pendingTaps,
      pendingCoins: pendingCoins ?? this.pendingCoins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingPassive: pendingPassive,
      newlyUnlockedAchievement: newlyUnlockedAchievement,
    );
  }

  // Helpers
  bool get hasUser => user != null;
  bool get canClaim => pendingTaps >= AppConstants.tapsPerClaim;
  double get claimProgress => pendingTaps / AppConstants.tapsPerClaim;
  int get tapsUntilClaim => AppConstants.tapsPerClaim - pendingTaps;
}

class GameNotifier extends StateNotifier<GameState> {
  final ApiService _apiService;
  final GameService _gameService;
  final FirestoreService _firestoreService;
  final AuthService _authService;
  Timer? _passiveTimer;

  GameNotifier(
    this._apiService,
    this._gameService,
    this._firestoreService,
    this._authService,
  ) : super(const GameState());

  /// Initialize game for a user
  Future<void> initializeGame(String uid) async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize API service
      await _apiService.initialize();

      // Check if user is banned
      final stats = await _apiService.getUserStats(uid);
      if (stats?.banned == true) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Account Suspended: ${stats?.banReason ?? "Violation of terms"}',
        );
        return;
      }

      // Load user data (Local First)
      UserModel? user = await _gameService.getLocalUser(uid);

      // If not local, try remote (first login on this device)
      if (user == null) {
        user = await _firestoreService.getUser(uid);
        if (user != null) {
          await _gameService.saveUserLocal(user);
        }
      }

      // If still null, create new user (First time ever)
      if (user == null) {
        // Get user details from auth service
        final currentUser = _authService.currentUser;
        user = _gameService.createNewUser(
          uid: uid,
          email: currentUser?.email,
          displayName: currentUser?.displayName,
          photoURL: currentUser?.photoURL,
        );

        // Sync to Firestore immediately
        await _firestoreService.createUser(user);
      }

      // Check for daily reset
      user = _checkDailyReset(user);
      await _gameService.saveUserLocal(user); // Save reset if needed

      // Load upgrades (Local First)
      // For now we trust the user model's embedded data or fetch from local box (if we split them)
      // The current Firestore service separate fetch is fine for initial, but we should cache it.
      // Simplification: We assume upgrades are mostly static config + user level.
      final ownedUpgrades = await _firestoreService.getUpgrades(
        uid,
      ); // Keep this for now or move to local

      final allUpgrades = _gameService.getAllUpgrades(ownedUpgrades);
      // Update cooling rate
      _gameService.updateActiveCoolingRate(
        _gameService.calculateTotalCooling(allUpgrades),
      );
      // ... content continues ...

      // Load achievements (Currently Firestore, should migrate to local)
      final savedAchievements = await _firestoreService.getAchievements(uid);
      final allAchievements = _gameService.getAllAchievements(
        user,
        savedAchievements,
      );

      // Calculate pending passive
      final pendingPassive = _gameService.calculatePassiveEarnings(user);

      state = state.copyWith(
        user: user,
        upgrades: allUpgrades,
        achievements: allAchievements,
        ownedUpgrades: ownedUpgrades,
        isLoading: false,
        pendingPassive: pendingPassive.hasEarnings ? pendingPassive : null,
      );

      // Start passive timer
      _startPassiveTimer();

      // Start session
      _gameService.startSession();

      // Check for referral rewards
      _checkReferralRewards();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Initialize with demo user (for testing without auth)
  void initializeDemo() {
    final demoUser = UserModel(
      uid: 'demo_user',
      displayName: 'Demo Miner',
      email: 'demo@mining.app',
      createdAt: DateTime.now(),
      referralCode: 'DEMO12345',
      coinBalance: 50000,
      tapPower: 1.0,
      passiveRate: 0.5,
      lastPassiveClaim: DateTime.now().subtract(const Duration(hours: 2)),
      loginStreak: 3,
      lastLoginDate: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 1))),
    );

    final allUpgrades = _gameService.getAllUpgrades([]);
    // Update cooling rate
    _gameService.updateActiveCoolingRate(
      _gameService.calculateTotalCooling(allUpgrades),
    );
    final allAchievements = _gameService.getAllAchievements(demoUser, []);
    final pendingPassive = _gameService.calculatePassiveEarnings(demoUser);

    state = state.copyWith(
      user: demoUser,
      upgrades: allUpgrades,
      achievements: allAchievements,
      pendingPassive: pendingPassive.hasEarnings ? pendingPassive : null,
    );

    _gameService.startSession();
  }

  /// Check and perform daily reset
  UserModel _checkDailyReset(UserModel user) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (user.lastLoginDate != today) {
      // Reset daily counters
      return user.copyWith(dailyTaps: 0, dailyPassiveEarned: 0);
    }
    return user;
  }

  /// Start passive timer for real-time updates
  void _startPassiveTimer() {
    _passiveTimer?.cancel();
    _passiveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.user != null) {
        final pendingPassive = _gameService.calculatePassiveEarnings(
          state.user!,
        );
        if (pendingPassive.hasEarnings) {
          state = state.copyWith(pendingPassive: pendingPassive);
        }
      }
    });
  }

  /// Handle tap
  void tap() {
    if (state.user == null) return;

    final result = _gameService.processTap(state.user!);

    if (result.success) {
      // Haptic Feedback
      if (state.user!.isHapticEnabled) {
        // Use built-in or plugin. Plugin 'vibration' is in pubspec.
        // Calling it safely.
        // We need to import 'package:vibration/vibration.dart' or 'package:flutter/services.dart' for HapticFeedback.
        // Let's use Flutter's HapticFeedback for simplicity if it works, or Vibration.
        HapticFeedback.lightImpact();
      }

      // Update local state (Optimistic)
      state = state.copyWith(
        pendingTaps: state.pendingTaps + 1,
        pendingCoins: state.pendingCoins + result.coinsEarned,
        user: state.user!.copyWith(
          totalTaps: state.user!.totalTaps + 1,
          dailyTaps: state.user!.dailyTaps + 1,
        ),
      );

      // Save to local storage periodically?
      // For performance, maybe don't await every single tap save.
      // But if we crash, we lose progress.
      // Let's safe-guard by saving the User Model every X taps or on Claim.
      // For now, let's keep it in memory state (pendingTaps) until Claim.
      // Wait, user.dailyTaps is updated in state but not saved to box yet.

      // Check achievements
      _checkAchievements();
    }
  }

  /// Claim tap rewards (after watching ad)
  Future<void> claimTapRewards() async {
    if (!state.canClaim || state.user == null) return;

    // Validate locally (Server trust migrated to periodic sync)
    // We trust the client for now, as we moved to Offline-First.

    // Calculate actual coins (no server validation step here)
    final validCoins = state.pendingCoins;

    // Add coins to balance
    final newBalance = state.user!.coinBalance + validCoins;
    final newLifetimeEarned = state.user!.lifetimeCoinsEarned + validCoins;

    final updatedUser = state.user!.copyWith(
      coinBalance: newBalance,
      lifetimeCoinsEarned: newLifetimeEarned,
      // totalTaps/dailyTaps already updated in tap() state, just need saving
    );

    state = state.copyWith(user: updatedUser, pendingTaps: 0, pendingCoins: 0);

    // Sync to Local Storage
    await _gameService.saveUserLocal(state.user!);

    // Note: We do NOT sync to Firestore here anymore.
    // It happens via _performPeriodicSync in GameService.

    _checkAchievements();
  }

  /// Claim passive earnings (after watching ad)
  Future<void> claimPassiveEarnings() async {
    if (state.pendingPassive == null || state.user == null) return;

    final coins = state.pendingPassive!.coins;
    final newBalance = state.user!.coinBalance + coins;
    final newTotalPassive = state.user!.totalPassiveEarned + coins;
    final newDailyPassive = state.user!.dailyPassiveEarned + coins;
    final newLifetimeEarned = state.user!.lifetimeCoinsEarned + coins;

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lastPassiveClaim: DateTime.now(),
        dailyPassiveEarned: newDailyPassive,
        totalPassiveEarned: newTotalPassive,
        lifetimeCoinsEarned: newLifetimeEarned,
      ),
      pendingPassive: null,
    );

    // Sync to Local Storage
    await _gameService.saveUserLocal(state.user!);

    _checkAchievements();
  }

  /// Purchase upgrade
  Future<bool> purchaseUpgrade(UpgradeModel upgrade) async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true);

    PurchaseResult result;
    try {
      result = await _gameService.purchaseUpgrade(state.user!, upgrade);
    } finally {
      state = state.copyWith(isLoading: false);
    }

    if (!result.success) {
      return false;
    }

    // Update user balance
    final newBalance = state.user!.coinBalance - result.coinsSpent!;
    final newSpent = state.user!.lifetimeCoinsSpent + result.coinsSpent!;

    // Update upgrade
    final upgradedModel = upgrade.copyWith(
      level: result.newLevel,
      unlocked: true,
    );

    // Update owned upgrades
    List<OwnedUpgrade> newOwnedUpgrades = List.from(state.ownedUpgrades);
    final existingIndex = newOwnedUpgrades.indexWhere(
      (u) => u.upgradeId == upgrade.id,
    );

    if (existingIndex >= 0) {
      newOwnedUpgrades[existingIndex] =
          newOwnedUpgrades[existingIndex].copyWith(level: result.newLevel);
    } else {
      newOwnedUpgrades.add(
        OwnedUpgrade(
          upgradeId: upgrade.id,
          tier: upgrade.tier,
          level: result.newLevel!,
          purchasedAt: DateTime.now(),
        ),
      );
    }

    // Update all upgrades list
    final newUpgrades = state.upgrades.map((u) {
      if (u.id == upgrade.id) return upgradedModel;
      return u;
    }).toList();

    // Calculate new tap power and passive rate
    final newTapPower = _gameService.calculateTotalTapPower(newUpgrades);
    final newPassiveRate = _gameService.calculateTotalPassiveRate(
      newUpgrades,
      hasPassiveUpgrade: state.user!.hasPassiveUpgrade,
    );

    // Update cooling rate
    _gameService.updateActiveCoolingRate(
      _gameService.calculateTotalCooling(newUpgrades),
    );

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lifetimeCoinsSpent: newSpent,
        tapPower: newTapPower,
        passiveRate: newPassiveRate,
      ),
      upgrades: newUpgrades,
      ownedUpgrades: newOwnedUpgrades,
    );

    // Sync to Local Storage
    await _gameService.saveUserLocal(state.user!);

    // We also need to save upgrades locally if we box them separately.
    // For now assuming upgrades are re-generated from User Model or saved in separate call.
    // _gameService.saveUpgradesLocal(...);

    _checkAchievements();
    return true;
  }

  /// Claim daily bonus
  Future<bool> claimDailyBonus() async {
    if (state.user == null) return false;

    final bonusInfo = _gameService.getDailyBonusInfo(state.user!);

    if (!bonusInfo.canClaim) return false;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final newBalance = state.user!.coinBalance + bonusInfo.bonusAmount;
    final newLifetimeEarned =
        state.user!.lifetimeCoinsEarned + bonusInfo.bonusAmount;

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lifetimeCoinsEarned: newLifetimeEarned,
        loginStreak: bonusInfo.currentStreak,
        lastLoginDate: today,
      ),
    );

    // Sync to Firestore
    try {
      await _firestoreService.updateUser(state.user!.uid, {
        'coinBalance': newBalance,
        'lifetimeCoinsEarned': newLifetimeEarned,
        'loginStreak': bonusInfo.currentStreak,
        'lastLoginDate': today,
      });
    } catch (e) {
      debugPrint('Error syncing daily bonus: $e');
    }

    // Save to Local
    await _gameService.saveUserLocal(state.user!);

    _checkAchievements();
    return true;
  }

  /// Claim achievement reward
  Future<bool> claimAchievement(AchievementModel achievement) async {
    if (state.user == null || !achievement.isClaimable) return false;

    // Update achievement
    final updatedAchievements = state.achievements.map((a) {
      if (a.id == achievement.id) {
        return a.copyWith(claimed: true);
      }
      return a;
    }).toList();

    // Update balance
    final newBalance = state.user!.coinBalance + achievement.rewardCoins;
    final newLifetimeEarned =
        state.user!.lifetimeCoinsEarned + achievement.rewardCoins;

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lifetimeCoinsEarned: newLifetimeEarned,
      ),
      achievements: updatedAchievements,
    );

    // Sync to Firestore
    try {
      await _firestoreService.updateUser(state.user!.uid, {
        'coinBalance': newBalance,
        'lifetimeCoinsEarned': newLifetimeEarned,
        'achievements': updatedAchievements.map((a) => a.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error syncing achievement: $e');
    }

    // Save to Local
    await _gameService.saveUserLocal(state.user!);

    return true;
  }

  /// Check for newly unlocked achievements
  void _checkAchievements() {
    if (state.user == null) return;

    final newAchievements = _gameService.getAllAchievements(
      state.user!,
      state.achievements,
    );
    final newlyUnlocked = _gameService.getNewlyUnlocked(
      state.achievements,
      newAchievements,
    );

    state = state.copyWith(
      achievements: newAchievements,
      newlyUnlockedAchievement:
          newlyUnlocked.isNotEmpty ? newlyUnlocked.first : null,
    );
  }

  /// Clear newly unlocked achievement notification
  void clearAchievementNotification() {
    state = state.copyWith(newlyUnlockedAchievement: null);
  }

  /// Add coins (from IAP or other sources)
  void addCoins(int amount) {
    if (state.user == null) return;

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: state.user!.coinBalance + amount,
        lifetimeCoinsEarned: state.user!.lifetimeCoinsEarned + amount,
      ),
    );
  }

  /// Grant purchased item (coins, boosts, etc.)
  Future<void> grantPurchase(String productId) async {
    if (state.user == null) return;

    // Determine what to grant based on productId
    // In a real app, this config might come from IAPProduct definitions or backend
    int coinReward = 0;
    bool removeAds = false;
    // Add other logic for boosts/VIP

    if (productId.contains('coin') || productId.contains('pack')) {
      // Example logic - ideally fetch product details
      if (productId == 'starter_pack') coinReward = 500000;
      if (productId == 'growth_pack') coinReward = 2000000;
      // Fetch dynamic if needed
    }

    if (productId == 'remove_ads_forever' || productId == 'vip_monthly') {
      removeAds = true;
    }

    bool passiveUpgrade = false;
    if (productId == 'passive_booster') {
      passiveUpgrade = true;
    }

    // Update state
    final newBalance = state.user!.coinBalance + coinReward;
    final newLifetime = state.user!.lifetimeCoinsEarned + coinReward;
    final adsRemoved = state.user!.adsRemoved || removeAds;
    final hasPassive = state.user!.hasPassiveUpgrade || passiveUpgrade;

    // Recalculate passive rate if upgraded
    double newPassiveRate = state.user!.passiveRate;
    if (passiveUpgrade) {
      newPassiveRate = _gameService.calculateTotalPassiveRate(
        state.upgrades,
        hasPassiveUpgrade: true,
      );
    }

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lifetimeCoinsEarned: newLifetime,
        adsRemoved: adsRemoved,
        hasPassiveUpgrade: hasPassive,
        passiveRate: newPassiveRate,
      ),
    );

    // Sync to Firestore
    try {
      await _firestoreService.updateUser(state.user!.uid, {
        'coinBalance': newBalance,
        'lifetimeCoinsEarned': newLifetime,
        'adsRemoved': adsRemoved,
        'hasPassiveUpgrade': hasPassive,
        'passiveRate': newPassiveRate,
        if (productId == 'vip_monthly')
          'vipUntil':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error syncing purchase: $e');
    }

    // Save to Local
    await _gameService.saveUserLocal(state.user!);
  }

  /// Toggle Notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (state.user == null) return;

    state = state.copyWith(
      user: state.user!.copyWith(isNotificationsEnabled: enabled),
    );
    await _gameService.saveUserLocal(state.user!);
  }

  /// Toggle Haptic Feedback
  Future<void> toggleHaptic(bool enabled) async {
    if (state.user == null) return;

    state = state.copyWith(
      user: state.user!.copyWith(isHapticEnabled: enabled),
    );
    await _gameService.saveUserLocal(state.user!);
  }

  /// Withdraw funds
  Future<bool> withdrawFunds(
    int amountCoins,
    String method,
    Map<String, String> details,
  ) async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      // 0. Force Sync before withdrawal to ensure server has latest balance
      final synced = await _gameService.syncState(state.user!.uid);
      if (!synced) {
        state = state.copyWith(error: 'Connection error. Please try again.');
        return false;
      }

      // 1. Call Worker (Server Authoritative)
      final validation = await _gameService.requestWithdrawal(
        uid: state.user!.uid,
        amountCoins: amountCoins,
        method: method,
        details: details,
      );

      if (validation.valid) {
        // ... (existing success logic)
        final newBalance = state.user!.coinBalance - amountCoins;
        state = state.copyWith(
          user: state.user!.copyWith(
            coinBalance: newBalance,
            lifetimeCoinsSpent: state.user!.lifetimeCoinsSpent + amountCoins,
          ),
        );
        return true;
      } else {
        state = state.copyWith(error: validation.message);
        return false;
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Claim ad reward (Client-side trust)
  Future<void> claimAdReward(int amount, String rewardType) async {
    if (state.user == null) return;

    final newBalance = state.user!.coinBalance + amount;
    final newLifetime = state.user!.lifetimeCoinsEarned + amount;

    state = state.copyWith(
      user: state.user!.copyWith(
        coinBalance: newBalance,
        lifetimeCoinsEarned: newLifetime,
      ),
    );

    await _gameService.saveUserLocal(state.user!);
  }

  /// Check referral rewards
  Future<void> _checkReferralRewards() async {
    if (state.user == null) return;

    try {
      final claimed = state.user!.claimedReferrals;
      final pendingUids = await _firestoreService.getPendingReferrals(
        state.user!.referralCode,
        claimed,
      );

      if (pendingUids.isEmpty) return;

      int totalReward = 0;
      final newlyClaimed = <String>[];

      for (final uid in pendingUids) {
        totalReward += AppConstants.referralReward;
        newlyClaimed.add(uid);
      }

      // Update state
      final newBalance = state.user!.coinBalance + totalReward;
      final newLifetime = state.user!.lifetimeCoinsEarned + totalReward;
      final newClaimedList = [...claimed, ...newlyClaimed];

      state = state.copyWith(
        user: state.user!.copyWith(
          coinBalance: newBalance,
          lifetimeCoinsEarned: newLifetime,
          claimedReferrals: newClaimedList,
        ),
      );

      // Save to Local Storage
      await _gameService.saveUserLocal(state.user!);

      // Also sync to Firestore immediately because referrals are an "Online" feature
      // and other users depend on this state (referrer needs to know I claimed).
      // Wait, if "referral" is online-only, we should keep the Firestore update here.
      // The requirement says "app will be completely store in the app only... but for... referral... this does not apply".
      // So keep Firestore update for referrals!

      await _firestoreService.updateUser(state.user!.uid, {
        'coinBalance': newBalance,
        'lifetimeCoinsEarned': newLifetime,
        'claimedReferrals': newClaimedList,
      });

      if (totalReward > 0) {
        debugPrint(
          'Claimed $totalReward coins from ${newlyClaimed.length} referrals',
        );
        // Ideally show a notification/toast to user
      }
    } catch (e) {
      debugPrint('Error checking referrals: $e');
    }
  }

  /// Redeem a referral code
  Future<String?> redeemReferralCode(String code) async {
    if (state.user == null) return 'Not logged in';
    if (state.user!.referredBy != null) return 'Already referred';
    if (state.user!.referralCode == code) return 'Cannot refer yourself';

    state = state.copyWith(isLoading: true);

    try {
      final result = await _gameService.redeemReferral(state.user!.uid, code);

      if (result['success'] == true) {
        final reward = result['reward'] as int;

        // Optimistic Update
        final newBalance = state.user!.coinBalance + reward;
        final newLifetime = state.user!.lifetimeCoinsEarned + reward;

        state = state.copyWith(
          user: state.user!.copyWith(
            coinBalance: newBalance,
            lifetimeCoinsEarned: newLifetime,
            referredBy: 'validated', // Or wait for sync
          ),
        );
        await _gameService.saveUserLocal(state.user!);

        return null; // Success (no error)
      } else {
        return result['message'] as String;
      }
    } catch (e) {
      return 'An error occurred';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _passiveTimer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final gameService = ref.watch(gameServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return GameNotifier(
    apiService,
    gameService,
    firestoreService,
    authService,
  );
});

// Convenience providers
final userProvider = Provider<UserModel?>((ref) {
  return ref.watch(gameProvider).user;
});

final coinBalanceProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).user?.coinBalance ?? 0;
});

final tapPowerProvider = Provider<double>((ref) {
  return ref.watch(gameProvider).user?.effectiveTapPower ?? 1.0;
});

final passiveRateProvider = Provider<double>((ref) {
  return ref.watch(gameProvider).user?.effectivePassiveRate ?? 0.5;
});

final upgradesProvider = Provider<List<UpgradeModel>>((ref) {
  return ref.watch(gameProvider).upgrades;
});

final achievementsProvider = Provider<List<AchievementModel>>((ref) {
  return ref.watch(gameProvider).achievements;
});

final pendingTapsProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).pendingTaps;
});

final pendingCoinsProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).pendingCoins;
});

final canClaimProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider).canClaim;
});

final pendingPassiveProvider = Provider<PassiveEarnings?>((ref) {
  return ref.watch(gameProvider).pendingPassive;
});

final dailyBonusProvider = Provider<DailyBonusInfo>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    return DailyBonusInfo(
      canClaim: false,
      currentStreak: 0,
      bonusAmount: 0,
      message: 'Login to claim',
    );
  }
  return GameService().getDailyBonusInfo(user);
});
