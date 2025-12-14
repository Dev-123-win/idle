import 'package:hive/hive.dart';

part 'upgrade_model.g.dart';

/// Upgrade types
enum UpgradeType { tap, passive }

/// Model for upgrades
@HiveType(typeId: 1)
class UpgradeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final int tier;

  @HiveField(4)
  final int baseCost;

  @HiveField(5)
  final double baseEffect;

  @HiveField(6)
  final String type; // 'tap' or 'passive'

  @HiveField(7)
  final int level;

  @HiveField(8)
  final bool unlocked;

  UpgradeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.tier,
    required this.baseCost,
    required this.baseEffect,
    required this.type,
    this.level = 0,
    this.unlocked = false,
  });

  UpgradeModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? tier,
    int? baseCost,
    double? baseEffect,
    String? type,
    int? level,
    bool? unlocked,
  }) {
    return UpgradeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      tier: tier ?? this.tier,
      baseCost: baseCost ?? this.baseCost,
      baseEffect: baseEffect ?? this.baseEffect,
      type: type ?? this.type,
      level: level ?? this.level,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  /// Calculate cost for next level
  int get currentCost {
    if (level == 0) return baseCost;
    // Cost increases by 15% per level
    return (baseCost * _pow(1.15, level)).round();
  }

  /// Calculate current effect
  double get currentEffect {
    if (level == 0) return 0;
    // Effect increases by 10% per level
    return baseEffect * _pow(1.10, level - 1);
  }

  /// Calculate effect at next level
  double get nextLevelEffect {
    return baseEffect * _pow(1.10, level);
  }

  /// Calculate cost for a specific level
  int costForLevel(int targetLevel) {
    if (targetLevel <= 0) return baseCost;
    return (baseCost * _pow(1.15, targetLevel - 1)).round();
  }

  /// Calculate effect at a specific level
  double effectAtLevel(int targetLevel) {
    if (targetLevel <= 0) return 0;
    return baseEffect * _pow(1.10, targetLevel - 1);
  }

  /// Check if upgrade is tap type
  bool get isTapUpgrade => type == 'tap';

  /// Check if upgrade is passive type
  bool get isPassiveUpgrade => type == 'passive';

  /// Check if max level reached
  bool get isMaxLevel => level >= 50;

  /// Power function for calculations
  static double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'tier': tier,
      'baseCost': baseCost,
      'baseEffect': baseEffect,
      'type': type,
      'level': level,
      'unlocked': unlocked,
    };
  }

  factory UpgradeModel.fromJson(Map<String, dynamic> json) {
    return UpgradeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '⚙️',
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      baseCost: (json['baseCost'] as num?)?.toInt() ?? 1000,
      baseEffect: (json['baseEffect'] as num?)?.toDouble() ?? 1.0,
      type: json['type'] as String? ?? 'tap',
      level: (json['level'] as num?)?.toInt() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }

  /// Get description based on type
  String get description {
    if (isTapUpgrade) {
      return '+${currentEffect.toStringAsFixed(1)} coins/tap';
    } else {
      return '+${currentEffect.toStringAsFixed(1)} coins/sec';
    }
  }

  /// Get next level description
  String get nextLevelDescription {
    if (isTapUpgrade) {
      return '+${nextLevelEffect.toStringAsFixed(1)} coins/tap';
    } else {
      return '+${nextLevelEffect.toStringAsFixed(1)} coins/sec';
    }
  }
}

/// Owned upgrade tracking
@HiveType(typeId: 2)
class OwnedUpgrade {
  @HiveField(0)
  final String upgradeId;

  @HiveField(1)
  final int tier;

  @HiveField(2)
  final int level;

  @HiveField(3)
  final DateTime purchasedAt;

  OwnedUpgrade({
    required this.upgradeId,
    required this.tier,
    required this.level,
    required this.purchasedAt,
  });

  OwnedUpgrade copyWith({
    String? upgradeId,
    int? tier,
    int? level,
    DateTime? purchasedAt,
  }) {
    return OwnedUpgrade(
      upgradeId: upgradeId ?? this.upgradeId,
      tier: tier ?? this.tier,
      level: level ?? this.level,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upgradeId': upgradeId,
      'tier': tier,
      'level': level,
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }

  factory OwnedUpgrade.fromJson(Map<String, dynamic> json) {
    return OwnedUpgrade(
      upgradeId: json['upgradeId'] as String,
      tier: (json['tier'] as num?)?.toInt() ?? 1,
      level: (json['level'] as num?)?.toInt() ?? 1,
      purchasedAt: json['purchasedAt'] != null
          ? DateTime.parse(json['purchasedAt'] as String)
          : DateTime.now(),
    );
  }
}
