import 'dart:math';
import 'dart:convert';
import 'dart:async';
import '../repositories/local_game_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/upgrade_model.dart';
import '../models/achievement_model.dart';
import '../models/withdrawal_model.dart';
import 'firestore_service.dart';
import 'security_service.dart';
import 'device_info_service.dart';

/// Core game logic service
class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final SecurityService _securityService = SecurityService();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final Uuid _uuid = const Uuid();

  String? _deviceId;

  // Session state for behavioral analysis (F10.3)
  String? _sessionId;
  DateTime? _sessionStart;
  int _sessionTaps = 0;
  int _sessionCoinsEarned = 0;
  final List<DateTime> _recentTapTimes = [];
  final List<int> _actionIntervals = []; // Track time between actions
  DateTime? _lastActionTime;

  // CLIENT-SIDE STORAGE
  // CLIENT-SIDE STORAGE
  final LocalGameRepository _localRepo = LocalGameRepository();

  // SYNC CONFIG
  static const String _workerUrl = AppConstants.cloudflareWorkerBaseUrl;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;

  String? get sessionId => _sessionId;

  // Behavioral flags
  final List<String> _behavioralFlags = [];
  static const int _maxTapsPerSecond = AppConstants.maxTapsPerSecond;
  static const int _flagThresholdVelocity =
      200000; // 200K coins/hour is suspicious

  /// Initialize Local Storage
  Future<void> initLocal() async {
    await _localRepo.init();
  }

  /// Start a new session
  Future<void> startSession() async {
    // 1. Ensure Device ID
    _deviceId = await _deviceInfoService.getDeviceId();

    _sessionId = _uuid.v4();
    _sessionStart = DateTime.now();
    _sessionTaps = 0;
    _sessionCoinsEarned = 0;
    _recentTapTimes.clear();
    _actionIntervals.clear();
    _lastActionTime = null;
    _behavioralFlags.clear();

    // Start Optimized Periodic Sync (Every 4 hours)
    // Offline-First Model: Syncs large batches less frequently
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(hours: 4),
      (_) => syncState(getCurrentUserId()),
    );

    // Start Thermal System
    _startCoolingSystem();
  }

  // Helper to get uid
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Stop session
  void dispose() {
    _periodicSyncTimer?.cancel();
    // opportunistic sync on close
    if (getCurrentUserId().isNotEmpty) {
      syncState(getCurrentUserId());
    }
  }

  /// Record coins earned for velocity tracking
  void recordEarning(int coins) {
    _sessionCoinsEarned += coins;
    _recordAction();
    _checkEarningVelocity();
  }

  /// Record action time for pattern analysis
  void _recordAction() {
    final now = DateTime.now();
    if (_lastActionTime != null) {
      final interval = now.difference(_lastActionTime!).inMilliseconds;
      _actionIntervals.add(interval);

      // Keep only last 50 intervals
      if (_actionIntervals.length > 50) {
        _actionIntervals.removeAt(0);
      }
    }
    _lastActionTime = now;
  }

  /// Check for suspicious earning velocity (F10.3)
  void _checkEarningVelocity() {
    if (_sessionStart == null) return;

    final sessionDuration = DateTime.now().difference(_sessionStart!);
    if (sessionDuration.inMinutes < 5) return; // Need some data first

    // Calculate coins per hour
    final hoursPlayed = sessionDuration.inSeconds / 3600;
    if (hoursPlayed == 0) return;

    final coinsPerHour = _sessionCoinsEarned / hoursPlayed;

    if (coinsPerHour > _flagThresholdVelocity) {
      if (!_behavioralFlags.contains('high_velocity')) {
        _behavioralFlags.add('high_velocity');
        debugPrint(
          'BEHAVIORAL FLAG: High earning velocity: ${coinsPerHour.toStringAsFixed(0)} coins/hr',
        );
      }
    }
  }

  /// Check for bot-like behavior (consistent timing)
  bool _checkBotBehavior() {
    if (_actionIntervals.length < 20) return false;

    // Calculate variance in action intervals
    final sum = _actionIntervals.reduce((a, b) => a + b);
    final mean = sum / _actionIntervals.length;

    final variance = _actionIntervals
            .map((i) => (i - mean) * (i - mean))
            .reduce((a, b) => a + b) /
        _actionIntervals.length;
    final stdDev = _sqrtHelper(variance);

    // If standard deviation is very low (< 50ms), timing is too consistent
    if (stdDev < 50 && mean > 0) {
      if (!_behavioralFlags.contains('consistent_timing')) {
        _behavioralFlags.add('consistent_timing');
        debugPrint(
          'BEHAVIORAL FLAG: Suspiciously consistent timing (stdDev: ${stdDev.toStringAsFixed(1)}ms)',
        );
      }
      return true;
    }
    return false;
  }

  /// Get current behavioral analysis report
  BehavioralReport getBehavioralReport() {
    _checkBotBehavior();

    final sessionDuration = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    final hoursPlayed = sessionDuration.inSeconds / 3600;
    final coinsPerHour =
        hoursPlayed > 0 ? _sessionCoinsEarned / hoursPlayed : 0;

    return BehavioralReport(
      sessionDuration: sessionDuration,
      sessionTaps: _sessionTaps,
      sessionCoins: _sessionCoinsEarned,
      coinsPerHour: coinsPerHour.toInt(),
      flags: List.unmodifiable(_behavioralFlags),
      isSuspicious: _behavioralFlags.isNotEmpty,
    );
  }

  /// Get session duration
  Duration get sessionDuration => _sessionStart != null
      ? DateTime.now().difference(_sessionStart!)
      : Duration.zero;

  /// Sync behavioral report to Firestore for analysis
  Future<void> syncBehavioralReport(String uid) async {
    final report = getBehavioralReport();
    if (report.isSuspicious) {
      await _firestoreService.updateUser(uid, {
        'lastBehavioralReport': report.toJson(),
        'suspiciousFlags': report.flags,
      });
    }
  }

  /// Calculate square root for variance
  double _sqrtHelper(double value) {
    if (value <= 0) return 0;
    double x = value;
    double y = 1;
    const e = 0.00001;
    while (x - y > e) {
      x = (x + y) / 2;
      y = value / x;
    }
    return x;
  }

  /// Generate unique referral code
  String generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = StringBuffer('MINE');
    for (int i = 0; i < 5; i++) {
      code.write(chars[random.nextInt(chars.length)]);
    }
    return code.toString();
  }

  /// Create new user model
  UserModel createNewUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? referredBy,
  }) {
    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? 'Miner',
      photoURL: photoURL,
      createdAt: DateTime.now(),
      referralCode: generateReferralCode(),
      referredBy: referredBy,
      coinBalance: referredBy != null ? AppConstants.refereeBonus : 0,
      tapPower: AppConstants.baseTapPower.toDouble(),
      passiveRate: AppConstants.freePassiveRate,
      lastPassiveClaim: DateTime.now(),
      hasPassiveUpgrade: false,
    );

    // Save to local storage immediately
    saveUserLocal(user);

    return user;
  }

  // ===== LOCAL STORAGE =====

  /// Save user to local storage
  Future<void> saveUserLocal(UserModel user) async {
    await _localRepo.saveUser(user);
  }

  /// Get user from local storage
  Future<UserModel?> getLocalUser(String uid) async {
    return _localRepo.getUser();
  }

  // ===== TAP MECHANICS =====

  /// Check if tap is valid (anti-cheat)
  bool validateTap() {
    final now = DateTime.now();

    // Add current tap time
    _recentTapTimes.add(now);

    // Remove taps older than 1 second
    _recentTapTimes.removeWhere(
      (time) => now.difference(time).inMilliseconds > 1000,
    );

    // Check tap speed (max taps per second for anti-cheat)
    if (_recentTapTimes.length > _maxTapsPerSecond) {
      debugPrint(
        'Tap speed violation detected: ${_recentTapTimes.length} taps/sec',
      );
      return false;
    }

    return true;
  }

  // ===== THERMAL SYSTEM =====
  double _currentSystemHeat = 0.0;
  static const double _maxOptimalHeat = 100.0;
  static const double _maxThrottledHeat = 200.0;
  static const double _heatPerTap = 3.0; // Taps build heat fast
  Timer? _coolingTimer;

  void _startCoolingSystem() {
    _coolingTimer?.cancel();
    _coolingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentSystemHeat > 0) {
        _currentSystemHeat -= (_activeCoolingRate / 2); // /2 because 500ms
        if (_currentSystemHeat < 0) _currentSystemHeat = 0;
      }
    });
  }

  /// Process a tap (Server Authoritative) with Thermal Throttling
  TapResult processTap(UserModel user) {
    // 1. Anti-cheat (Speed Limit) still applies generally
    if (!validateTap()) {
      return TapResult(
        success: false,
        coinsEarned: 0,
        message: 'Tap limit!',
        currentHeat: _currentSystemHeat,
        maxHeat: _maxThrottledHeat,
      );
    }

    if (user.dailyTaps >= AppConstants.dailyTapCap) {
      // ... (existing cap logic)
      return TapResult(success: false, coinsEarned: 0, message: 'Daily limit!');
    }

    // 2. Thermal Logic
    // Increase Heat
    _currentSystemHeat += _heatPerTap;

    // Calculate Multiplier based on Zones
    double efficiency = 1.0;
    String statusMsg = '';

    if (_currentSystemHeat <= _maxOptimalHeat) {
      // Optimal Zone
      efficiency = 1.0;
      statusMsg = 'Optimal';
    } else if (_currentSystemHeat <= _maxThrottledHeat) {
      // Throttled Zone
      efficiency = 0.5;
      statusMsg = 'Heating Up!';
    } else {
      // Overheated Zone
      efficiency = 0.01; // 1% Reward
      statusMsg = 'OVERHEATED!';
    }

    // 3. Calculate Reward
    int baseEarn = user.effectiveTapPower.round();
    int actualEarn = (baseEarn * efficiency).floor();
    if (actualEarn < 1) actualEarn = 1; // Minimum 1 coin unless 0 base

    // 4. Update Stats
    _sessionTaps++;

    return TapResult(
      success: true,
      coinsEarned: actualEarn,
      message: statusMsg,
      currentHeat: _currentSystemHeat,
      maxHeat: _maxThrottledHeat, // Return the "Red Line" as max for UI bar
    );
  }

  double get currentSystemHeat => _currentSystemHeat;
  double get maxSystemHeat => _maxThrottledHeat;
  double get maxOptimalHeat => _maxOptimalHeat;

  void nitrogenFlush() {
    _currentSystemHeat = 0.0;
  }

  /// Perform Periodic/Forced Sync
  Future<bool> syncState(String uid) async {
    if (_isSyncing || uid.isEmpty) return false;

    final user = await getLocalUser(uid);
    if (user == null) return false;

    _isSyncing = true;
    debugPrint('Starting periodic sync...');

    try {
      final body = {
        'uid': uid,
        'totalTaps': user.totalTaps,
        'coinBalance': user.coinBalance,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _deviceId,
        // Send full state
        'ownedUpgrades': user.ownedUpgrades.map((u) => u.toJson()).toList(),
        'achievements': user.achievements.map((a) => a.toJson()).toList(),
        'loginStreak': user.loginStreak,
        'lastLoginDate': user.lastLoginDate,
      };

      final response = await http.post(
        Uri.parse('$_workerUrl/api/sync-state'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('Periodic sync successful');
        // We could clear a "dirty" flag here if we had one
        return true;
      } else {
        debugPrint('Periodic sync failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Periodic Sync Error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Redeem referral code
  Future<Map<String, dynamic>> redeemReferral(String uid, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_workerUrl/api/claim-referral'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid, 'code': code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Success
        // Update local state is difficult as we don't return full user here.
        // We generally should trigger a sync or forced user path.
        // For now, return success and let UI/Notifier handle local update (optimistic or re-fetch).
        return {'success': true, 'reward': data['reward']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to redeem'
        };
      }
    } catch (e) {
      debugPrint('Referral Error: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }

  /// Check if claim is needed (every 100 taps)
  bool shouldShowClaimPopup(int pendingTaps) {
    return pendingTaps >= AppConstants.tapsPerClaim;
  }

  // ===== PASSIVE MINING =====

  /// Calculate passive earnings since last claim
  PassiveEarnings calculatePassiveEarnings(UserModel user) {
    if (user.lastPassiveClaim == null) {
      return PassiveEarnings(coins: 0, duration: Duration.zero);
    }

    // Security check: If unsafe, force free tier limits
    final isSafe = _securityService.status.isSafe;
    final hasPremium = user.hasPassiveUpgrade && isSafe;

    final now = DateTime.now();
    final lastClaim = user.lastPassiveClaim!;
    final elapsed = now.difference(lastClaim);

    // Determine limits based on IAP
    final maxHours = hasPremium
        ? AppConstants.premiumOfflineHours
        : AppConstants.freeOfflineHours;

    final dailyCap = hasPremium
        ? AppConstants.premiumDailyPassiveCap
        : AppConstants.freeDailyPassiveCap;

    // Cap at max hours
    final maxDuration = Duration(hours: maxHours);
    final effectiveDuration = elapsed > maxDuration ? maxDuration : elapsed;

    // Calculate coins
    final seconds = effectiveDuration.inSeconds;
    final coinsEarned = (seconds * user.effectivePassiveRate).round();

    // Check daily passive cap
    final remainingCap = dailyCap - user.dailyPassiveEarned;
    final cappedCoins = coinsEarned > remainingCap ? remainingCap : coinsEarned;

    return PassiveEarnings(coins: cappedCoins, duration: effectiveDuration);
  }

  // ===== UPGRADES =====

  /// Get all available upgrades with current user levels
  List<UpgradeModel> getAllUpgrades(List<OwnedUpgrade> ownedUpgrades) {
    final upgrades = <UpgradeModel>[];

    // Tap upgrades
    for (int i = 0; i < UpgradeTiers.tapUpgrades.length; i++) {
      final tier = UpgradeTiers.tapUpgrades[i];
      final owned = ownedUpgrades.firstWhere(
        (u) => u.upgradeId == tier['id'],
        orElse: () => OwnedUpgrade(
          upgradeId: tier['id'] as String,
          tier: i + 1,
          level: 0,
          purchasedAt: DateTime.now(),
        ),
      );

      upgrades.add(
        UpgradeModel(
          id: tier['id'] as String,
          name: tier['name'] as String,
          icon: tier['icon'] as String,
          tier: i + 1,
          baseCost: tier['cost'] as int,
          baseEffect: (tier['effect'] as num).toDouble(),
          type: 'tap',
          level: owned.level,
          unlocked: owned.level > 0,
        ),
      );
    }

    // Passive upgrades
    for (int i = 0; i < UpgradeTiers.passiveUpgrades.length; i++) {
      final tier = UpgradeTiers.passiveUpgrades[i];
      final owned = ownedUpgrades.firstWhere(
        (u) => u.upgradeId == tier['id'],
        orElse: () => OwnedUpgrade(
          upgradeId: tier['id'] as String,
          tier: i + 1,
          level: 0,
          purchasedAt: DateTime.now(),
        ),
      );

      upgrades.add(
        UpgradeModel(
          id: tier['id'] as String,
          name: tier['name'] as String,
          icon: tier['icon'] as String,
          tier: i + 1,
          baseCost: tier['cost'] as int,
          baseEffect: (tier['effect'] as num).toDouble(),
          type: 'passive',
          level: owned.level,
          unlocked: owned.level > 0,
        ),
      );
    }

    // Cooling upgrades
    for (int i = 0; i < UpgradeTiers.coolingUpgrades.length; i++) {
      final tier = UpgradeTiers.coolingUpgrades[i];
      final owned = ownedUpgrades.firstWhere(
        (u) => u.upgradeId == tier['id'],
        orElse: () => OwnedUpgrade(
          upgradeId: tier['id'] as String,
          tier: i + 1,
          level: 0,
          purchasedAt: DateTime.now(),
        ),
      );

      upgrades.add(
        UpgradeModel(
          id: tier['id'] as String,
          name: tier['name'] as String,
          icon: tier['icon'] as String,
          tier: i + 1,
          baseCost: tier['cost'] as int,
          baseEffect: (tier['effect'] as num).toDouble(),
          type: 'cooling',
          level: owned.level,
          unlocked: owned.level > 0,
        ),
      );
    }

    return upgrades;
  }

  /// Purchase or upgrade (Local First)
  Future<PurchaseResult> purchaseUpgrade(
    UserModel user,
    UpgradeModel upgrade,
  ) async {
    // 1. Local Pre-check
    if (user.coinBalance < upgrade.currentCost) {
      return PurchaseResult(success: false, message: 'Not enough coins!');
    }

    try {
      // Calculate new level
      final newLevel = upgrade.level + 1;
      final cost = upgrade.currentCost;

      // We rely on GameNotifier to update the UserModel and save it to LocalRepo.
      // Next syncState() will pick up the new ownedUpgrades list.

      return PurchaseResult(
        success: true,
        message: 'Upgrade Successful!',
        newLevel: newLevel,
        coinsSpent: cost,
      );
    } catch (e) {
      debugPrint('Purchase Error: $e');
      return PurchaseResult(
        success: false,
        message: 'Error processing purchase',
      );
    }
  }

  /// Calculate total tap power from upgrades
  double calculateTotalTapPower(List<UpgradeModel> upgrades) {
    double total = AppConstants.baseTapPower.toDouble();
    for (final upgrade in upgrades.where(
      (u) => u.isTapUpgrade && u.level > 0,
    )) {
      total += upgrade.currentEffect;
    }
    return total;
  }

  /// Calculate total passive rate from upgrades
  double calculateTotalPassiveRate(
    List<UpgradeModel> upgrades, {
    bool hasPassiveUpgrade = false,
  }) {
    double total = hasPassiveUpgrade
        ? AppConstants.premiumPassiveRate
        : AppConstants.freePassiveRate;

    for (final upgrade in upgrades.where(
      (u) => u.isPassiveUpgrade && u.level > 0,
    )) {
      total += upgrade.currentEffect;
    }
    return total;
  }

  // Cooling Rate Helper
  double _activeCoolingRate = 10.0;

  void updateActiveCoolingRate(double rate) {
    _activeCoolingRate = rate;
  }

  /// Calculate total cooling rate from upgrades
  double calculateTotalCooling(List<UpgradeModel> upgrades) {
    double total = 10.0; // Base cooling
    for (final upgrade in upgrades.where(
      (u) => u.type == 'cooling' && u.level > 0,
    )) {
      total += upgrade.currentEffect;
    }
    return total;
  }

  // ===== DAILY BONUS =====

  /// Get daily bonus info
  DailyBonusInfo getDailyBonusInfo(UserModel user) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    // Check if already claimed today
    if (user.lastLoginDate == today) {
      return DailyBonusInfo(
        canClaim: false,
        currentStreak: user.loginStreak,
        bonusAmount: 0,
        message: 'Already claimed today!',
      );
    }

    // Check if streak continues
    int newStreak = user.loginStreak;
    if (user.lastLoginDate != null) {
      final lastLogin = DateTime.parse(user.lastLoginDate!);
      final difference = now.difference(lastLogin).inDays;

      if (difference > 1) {
        // Streak broken
        newStreak = 1;
      } else {
        newStreak = user.loginStreak + 1;
      }
    } else {
      newStreak = 1;
    }

    // Get bonus amount
    int bonusAmount;
    if (AppConstants.dailyBonusAmounts.containsKey(newStreak)) {
      bonusAmount = AppConstants.dailyBonusAmounts[newStreak]!;
    } else if (newStreak <= 6) {
      bonusAmount = 500;
    } else {
      bonusAmount = 500;
    }

    return DailyBonusInfo(
      canClaim: true,
      currentStreak: newStreak,
      bonusAmount: bonusAmount,
      message: 'Day $newStreak bonus!',
    );
  }

  // ===== ACHIEVEMENTS =====

  /// Get all achievements with progress
  List<AchievementModel> getAllAchievements(
    UserModel user,
    List<AchievementModel> saved,
  ) {
    final achievements = <AchievementModel>[];

    for (final def in AchievementDefinitions.achievements) {
      final savedAchievement = saved.firstWhere(
        (a) => a.id == def['id'],
        orElse: () => AchievementModel.fromDefinition(def),
      );

      // Calculate progress
      double progress = 0;
      switch (def['id']) {
        case 'first_tap':
          progress = user.totalTaps > 0 ? 1 : 0;
          break;
        case 'century':
          progress = min(user.totalTaps.toDouble(), 100);
          break;
        case '1k_taps':
          progress = min(user.totalTaps.toDouble(), 1000);
          break;
        case '10k_taps':
          progress = min(user.totalTaps.toDouble(), 10000);
          break;
        case '50k_taps':
          progress = min(user.totalTaps.toDouble(), 50000);
          break;
        case 'tap_god':
          progress = min(user.totalTaps.toDouble(), 100000);
          break;
        case 'passive_starter':
          progress = min(user.totalPassiveEarned.toDouble(), 10000);
          break;
        case 'passive_pro':
          progress = min(user.totalPassiveEarned.toDouble(), 100000);
          break;
        case 'week_warrior':
          progress = min(user.loginStreak.toDouble(), 7);
          break;
        case '100k_club':
          progress = min(user.lifetimeCoinsEarned.toDouble(), 100000);
          break;
        case 'millionaire':
          progress = min(user.lifetimeCoinsEarned.toDouble(), 1000000);
          break;
        case 'big_spender':
          progress = min(user.lifetimeCoinsSpent.toDouble(), 50000);
          break;
        default:
          progress = savedAchievement.progress;
      }

      final unlocked = progress >= savedAchievement.targetValue;

      achievements.add(
        savedAchievement.copyWith(
          progress: progress,
          unlocked: unlocked || savedAchievement.unlocked,
          unlockedAt: unlocked && savedAchievement.unlockedAt == null
              ? DateTime.now()
              : savedAchievement.unlockedAt,
        ),
      );
    }

    return achievements;
  }

  /// Check for newly unlocked achievements
  List<AchievementModel> getNewlyUnlocked(
    List<AchievementModel> before,
    List<AchievementModel> after,
  ) {
    return after.where((a) {
      final beforeAchievement = before.firstWhere(
        (b) => b.id == a.id,
        orElse: () => a,
      );
      return a.unlocked && !beforeAchievement.unlocked;
    }).toList();
  }

  // ===== WITHDRAWALS =====

  /// Validate withdrawal request
  WithdrawalValidation validateWithdrawal(UserModel user, int coins) {
    // Check email verification
    if (!user.emailVerified) {
      return WithdrawalValidation(
        valid: false,
        message: 'Please verify your email first',
      );
    }

    // Check minimum
    if (coins < AppConstants.minWithdrawalCoins) {
      return WithdrawalValidation(
        valid: false,
        message: 'Minimum withdrawal is ₹${AppConstants.minWithdrawalINR}',
      );
    }

    // Check balance
    if (user.coinBalance < coins) {
      return WithdrawalValidation(
        valid: false,
        message: 'Insufficient balance',
      );
    }

    // Calculate amounts
    final coinsAfterFee = coins - AppConstants.processingFeeCoins;
    final inrAmount = coinsAfterFee / AppConstants.coinsPerINR;

    // Check maximum
    if (inrAmount > AppConstants.maxWithdrawalINR) {
      return WithdrawalValidation(
        valid: false,
        message: 'Maximum withdrawal is ₹${AppConstants.maxWithdrawalINR}',
      );
    }

    return WithdrawalValidation(
      valid: true,
      message: 'Valid withdrawal request',
      netAmount: inrAmount,
      processingFee: AppConstants.processingFeeCoins / AppConstants.coinsPerINR,
    );
  }

  /// Process Withdrawal (Server Authoritative)
  Future<WithdrawalValidation> requestWithdrawal({
    required String uid,
    required int amountCoins,
    required String method,
    Map<String, dynamic>? details,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_workerUrl/api/withdraw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'amountCoins': amountCoins,
          'method': method,
          'details': details ?? {},
        }),
      );

      if (response.statusCode == 200) {
        return WithdrawalValidation(valid: true, message: 'Request Submitted!');
      } else {
        final err = jsonDecode(response.body);
        return WithdrawalValidation(valid: false, message: err['error']);
      }
    } catch (e) {
      return WithdrawalValidation(valid: false, message: 'Network Error');
    }
  }

  // ===== TRANSACTIONS =====

  /// Create a transaction record
  TransactionModel createTransaction({
    required String uid,
    required String type,
    required int amount,
    required String source,
    required String description,
    required int balanceBefore,
  }) {
    return TransactionModel(
      transactionId: _uuid.v4(),
      uid: uid,
      type: type,
      amount: amount,
      source: source,
      description: description,
      balanceBefore: balanceBefore,
      balanceAfter:
          type == 'earn' ? balanceBefore + amount : balanceBefore - amount,
      createdAt: DateTime.now(),
    );
  }

  // ===== HELPERS =====

  /// Format coin amount
  String formatCoins(int coins) {
    if (coins >= 1000000000) {
      return '${(coins / 1000000000).toStringAsFixed(1)}B';
    } else if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###').format(coins);
  }

  /// Format INR amount
  String formatINR(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Format duration
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }
}

// ===== RESULT CLASSES =====

class TapResult {
  final bool success;
  final int coinsEarned;
  final String message;
  final double currentHeat; // New
  final double maxHeat; // New

  TapResult({
    required this.success,
    required this.coinsEarned,
    this.message = '', // Default to empty
    this.currentHeat = 0.0,
    this.maxHeat = 100.0,
  });
}

class PassiveEarnings {
  final int coins;
  final Duration duration;

  PassiveEarnings({required this.coins, required this.duration});

  bool get hasEarnings => coins > 0;
}

class PurchaseResult {
  final bool success;
  final String message;
  final int? coinsSpent;
  final int? newLevel;
  final double? effectGained;

  PurchaseResult({
    required this.success,
    required this.message,
    this.coinsSpent,
    this.newLevel,
    this.effectGained,
  });
}

class DailyBonusInfo {
  final bool canClaim;
  final int currentStreak;
  final int bonusAmount;
  final String message;

  DailyBonusInfo({
    required this.canClaim,
    required this.currentStreak,
    required this.bonusAmount,
    required this.message,
  });
}

class WithdrawalValidation {
  final bool valid;
  final String message;
  final double? netAmount;
  final double? processingFee;

  WithdrawalValidation({
    required this.valid,
    required this.message,
    this.netAmount,
    this.processingFee,
  });
}

/// Behavioral analysis report for anti-cheat (F10.3)
class BehavioralReport {
  final Duration sessionDuration;
  final int sessionTaps;
  final int sessionCoins;
  final int coinsPerHour;
  final List<String> flags;
  final bool isSuspicious;

  const BehavioralReport({
    required this.sessionDuration,
    required this.sessionTaps,
    required this.sessionCoins,
    required this.coinsPerHour,
    required this.flags,
    required this.isSuspicious,
  });

  Map<String, dynamic> toJson() => {
        'durationSeconds': sessionDuration.inSeconds,
        'taps': sessionTaps,
        'coins': sessionCoins,
        'coinsPerHour': coinsPerHour,
        'flags': flags,
      };

  @override
  String toString() =>
      'BehavioralReport(coins/hr: $coinsPerHour, flags: $flags, suspicious: $isSuspicious)';
}
