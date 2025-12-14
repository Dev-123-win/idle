import 'package:hive/hive.dart';
import 'upgrade_model.dart'; // Import before part

part 'user_model.g.dart';

/// User model for game state
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final String displayName;

  @HiveField(4)
  final String? photoURL;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String referralCode;

  @HiveField(7)
  final String? referredBy;

  // Balances
  @HiveField(8)
  final int coinBalance;

  @HiveField(9)
  final int lifetimeCoinsEarned;

  @HiveField(10)
  final int lifetimeCoinsSpent;

  // Gameplay
  @HiveField(11)
  final int totalTaps;

  @HiveField(12)
  final int dailyTaps;

  @HiveField(13)
  final DateTime? lastTapSync;

  @HiveField(14)
  final double tapPower;

  @HiveField(15)
  final double passiveRate;

  @HiveField(16)
  final DateTime? lastPassiveClaim;

  @HiveField(17)
  final int dailyPassiveEarned;

  // Daily bonus
  @HiveField(18)
  final int loginStreak;

  @HiveField(19)
  final String? lastLoginDate;

  // IAP status
  @HiveField(20)
  final bool adsRemoved;

  @HiveField(21)
  final DateTime? vipUntil;

  @HiveField(22)
  final double boostMultiplier;

  @HiveField(23)
  final DateTime? boostUntil;

  // Verification
  @HiveField(24)
  final bool emailVerified;

  // Total passive earned for achievements
  @HiveField(25)
  final int totalPassiveEarned;

  @HiveField(26)
  final List<String> claimedReferrals;

  @HiveField(27)
  final bool hasPassiveUpgrade;

  @HiveField(28)
  final List<OwnedUpgrade> ownedUpgrades;

  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.referralCode,
    this.referredBy,
    this.coinBalance = 0,
    this.lifetimeCoinsEarned = 0,
    this.lifetimeCoinsSpent = 0,
    this.totalTaps = 0,
    this.dailyTaps = 0,
    this.lastTapSync,
    this.tapPower = 1.0,
    this.passiveRate = 0.5,
    this.lastPassiveClaim,
    this.dailyPassiveEarned = 0,
    this.loginStreak = 0,
    this.lastLoginDate,
    this.adsRemoved = false,
    this.vipUntil,
    this.boostMultiplier = 1.0,
    this.boostUntil,
    this.emailVerified = false,
    this.totalPassiveEarned = 0,
    this.claimedReferrals = const [],
    this.hasPassiveUpgrade = false,
    this.ownedUpgrades = const [],
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    String? referralCode,
    String? referredBy,
    int? coinBalance,
    int? lifetimeCoinsEarned,
    int? lifetimeCoinsSpent,
    int? totalTaps,
    int? dailyTaps,
    DateTime? lastTapSync,
    double? tapPower,
    double? passiveRate,
    DateTime? lastPassiveClaim,
    int? dailyPassiveEarned,
    int? loginStreak,
    String? lastLoginDate,
    bool? adsRemoved,
    DateTime? vipUntil,
    double? boostMultiplier,
    DateTime? boostUntil,
    bool? emailVerified,
    int? totalPassiveEarned,
    List<String>? claimedReferrals,
    bool? hasPassiveUpgrade,
    List<OwnedUpgrade>? ownedUpgrades,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      coinBalance: coinBalance ?? this.coinBalance,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      lifetimeCoinsSpent: lifetimeCoinsSpent ?? this.lifetimeCoinsSpent,
      totalTaps: totalTaps ?? this.totalTaps,
      dailyTaps: dailyTaps ?? this.dailyTaps,
      lastTapSync: lastTapSync ?? this.lastTapSync,
      tapPower: tapPower ?? this.tapPower,
      passiveRate: passiveRate ?? this.passiveRate,
      lastPassiveClaim: lastPassiveClaim ?? this.lastPassiveClaim,
      dailyPassiveEarned: dailyPassiveEarned ?? this.dailyPassiveEarned,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      vipUntil: vipUntil ?? this.vipUntil,
      boostMultiplier: boostMultiplier ?? this.boostMultiplier,
      boostUntil: boostUntil ?? this.boostUntil,
      emailVerified: emailVerified ?? this.emailVerified,
      totalPassiveEarned: totalPassiveEarned ?? this.totalPassiveEarned,
      claimedReferrals: claimedReferrals ?? this.claimedReferrals,
      hasPassiveUpgrade: hasPassiveUpgrade ?? this.hasPassiveUpgrade,
      ownedUpgrades: ownedUpgrades ?? this.ownedUpgrades,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'referralCode': referralCode,
      'referredBy': referredBy,
      'coinBalance': coinBalance,
      'lifetimeCoinsEarned': lifetimeCoinsEarned,
      'lifetimeCoinsSpent': lifetimeCoinsSpent,
      'totalTaps': totalTaps,
      'dailyTaps': dailyTaps,
      'lastTapSync': lastTapSync?.toIso8601String(),
      'tapPower': tapPower,
      'passiveRate': passiveRate,
      'lastPassiveClaim': lastPassiveClaim?.toIso8601String(),
      'dailyPassiveEarned': dailyPassiveEarned,
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate,
      'adsRemoved': adsRemoved,
      'vipUntil': vipUntil?.toIso8601String(),
      'boostMultiplier': boostMultiplier,
      'boostUntil': boostUntil?.toIso8601String(),
      'emailVerified': emailVerified,
      'totalPassiveEarned': totalPassiveEarned,
      'claimedReferrals': claimedReferrals,
      'hasPassiveUpgrade': hasPassiveUpgrade,
      'ownedUpgrades': ownedUpgrades.map((u) => u.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String? ?? 'Miner',
      photoURL: json['photoURL'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      referralCode: json['referralCode'] as String? ?? '',
      referredBy: json['referredBy'] as String?,
      coinBalance: (json['coinBalance'] as num?)?.toInt() ?? 0,
      lifetimeCoinsEarned: (json['lifetimeCoinsEarned'] as num?)?.toInt() ?? 0,
      lifetimeCoinsSpent: (json['lifetimeCoinsSpent'] as num?)?.toInt() ?? 0,
      totalTaps: (json['totalTaps'] as num?)?.toInt() ?? 0,
      dailyTaps: (json['dailyTaps'] as num?)?.toInt() ?? 0,
      lastTapSync: json['lastTapSync'] != null
          ? DateTime.parse(json['lastTapSync'] as String)
          : null,
      tapPower: (json['tapPower'] as num?)?.toDouble() ?? 1.0,
      passiveRate: (json['passiveRate'] as num?)?.toDouble() ?? 0.5,
      lastPassiveClaim: json['lastPassiveClaim'] != null
          ? DateTime.parse(json['lastPassiveClaim'] as String)
          : null,
      dailyPassiveEarned: (json['dailyPassiveEarned'] as num?)?.toInt() ?? 0,
      loginStreak: (json['loginStreak'] as num?)?.toInt() ?? 0,
      lastLoginDate: json['lastLoginDate'] as String?,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      vipUntil: json['vipUntil'] != null
          ? DateTime.parse(json['vipUntil'] as String)
          : null,
      boostMultiplier: (json['boostMultiplier'] as num?)?.toDouble() ?? 1.0,
      boostUntil: json['boostUntil'] != null
          ? DateTime.parse(json['boostUntil'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
      totalPassiveEarned: (json['totalPassiveEarned'] as num?)?.toInt() ?? 0,
      claimedReferrals:
          (json['claimedReferrals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hasPassiveUpgrade: json['hasPassiveUpgrade'] as bool? ?? false,
      ownedUpgrades:
          (json['ownedUpgrades'] as List<dynamic>?)
              ?.map((e) => OwnedUpgrade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Helper methods
  bool get isVip => vipUntil != null && vipUntil!.isAfter(DateTime.now());

  bool get hasActiveBoost =>
      boostUntil != null && boostUntil!.isAfter(DateTime.now());

  double get effectiveBoostMultiplier => hasActiveBoost ? boostMultiplier : 1.0;

  double get effectiveTapPower =>
      tapPower * effectiveBoostMultiplier * (isVip ? 1.0 : 1.0);

  double get effectivePassiveRate =>
      passiveRate * (isVip ? 2.0 : 1.0) * effectiveBoostMultiplier;

  double get coinBalanceInINR => coinBalance / 10000;
}
