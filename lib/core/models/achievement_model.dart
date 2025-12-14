import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

/// Achievement categories
enum AchievementCategory { gettingStarted, tapMaster, passive, wealth, social }

/// Model for achievements
@HiveType(typeId: 3)
class AchievementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int rewardCoins;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool unlocked;

  @HiveField(6)
  final bool claimed;

  @HiveField(7)
  final DateTime? unlockedAt;

  @HiveField(8)
  final double progress;

  @HiveField(9)
  final double targetValue;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rewardCoins,
    required this.category,
    this.unlocked = false,
    this.claimed = false,
    this.unlockedAt,
    this.progress = 0,
    this.targetValue = 1,
  });

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    int? rewardCoins,
    String? category,
    bool? unlocked,
    bool? claimed,
    DateTime? unlockedAt,
    double? progress,
    double? targetValue,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      category: category ?? this.category,
      unlocked: unlocked ?? this.unlocked,
      claimed: claimed ?? this.claimed,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetValue <= 0) return unlocked ? 1.0 : 0.0;
    return (progress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if achievement is claimable
  bool get isClaimable => unlocked && !claimed;

  /// Get icon based on category
  String get icon {
    switch (category) {
      case 'getting_started':
        return '🎯';
      case 'tap_master':
        return '👆';
      case 'passive':
        return '💤';
      case 'wealth':
        return '💰';
      case 'social':
        return '👥';
      default:
        return '🏆';
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'getting_started':
        return 'Getting Started';
      case 'tap_master':
        return 'Tap Master';
      case 'passive':
        return 'Passive Income';
      case 'wealth':
        return 'Wealth Builder';
      case 'social':
        return 'Social';
      default:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rewardCoins': rewardCoins,
      'category': category,
      'unlocked': unlocked,
      'claimed': claimed,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'targetValue': targetValue,
    };
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'getting_started',
      unlocked: json['unlocked'] as bool? ?? false,
      claimed: json['claimed'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 1,
    );
  }

  /// Create from definition
  factory AchievementModel.fromDefinition(Map<String, dynamic> def) {
    return AchievementModel(
      id: def['id'] as String,
      name: def['name'] as String,
      description: def['desc'] as String? ?? '',
      rewardCoins: (def['reward'] as num?)?.toInt() ?? 0,
      category: def['category'] as String? ?? 'getting_started',
      targetValue: _getTargetValue(def['id'] as String),
    );
  }

  /// Get target value based on achievement ID
  static double _getTargetValue(String id) {
    switch (id) {
      case 'first_tap':
        return 1;
      case 'century':
        return 100;
      case '1k_taps':
        return 1000;
      case '10k_taps':
        return 10000;
      case '50k_taps':
        return 50000;
      case 'tap_god':
        return 100000;
      case 'speed_demon':
        return 50; // 50 taps in 10 seconds
      case 'passive_starter':
        return 10000;
      case 'passive_pro':
        return 100000;
      case 'overnight_earner':
        return 6; // 6 hours
      case 'week_warrior':
        return 7;
      case '100k_club':
        return 100000;
      case 'millionaire':
        return 1000000;
      case 'big_spender':
        return 50000;
      case 'investor':
        return 5;
      case 'friend_finder':
        return 1;
      case 'influencer':
        return 5;
      case 'ambassador':
        return 10;
      default:
        return 1;
    }
  }
}
