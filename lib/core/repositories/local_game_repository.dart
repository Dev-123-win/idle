import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/upgrade_model.dart';

class LocalGameRepository {
  static const String _userBoxName = 'user_data';
  static const String _syncBoxName = 'sync_data';

  // Keys
  static const String _userKey = 'current_user';
  static const String _pendingSyncKey = 'pending_sync';

  late Box<UserModel> _userBox;
  late Box _syncBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _userBox = await Hive.openBox<UserModel>(_userBoxName);
    _syncBox = await Hive.openBox(_syncBoxName);

    _initialized = true;
  }

  // User Methods
  Future<void> saveUser(UserModel user) async {
    await _userBox.put(_userKey, user);
  }

  UserModel? getUser() {
    return _userBox.get(_userKey);
  }

  Future<void> deleteUser() async {
    await _userBox.delete(_userKey);
  }

  // Pending Sync Methods
  // storing SyncData as JSON map to avoid code generation for now
  Future<void> savePendingSync(SyncData data) async {
    await _syncBox.put(_pendingSyncKey, data.toJson());
  }

  SyncData? getPendingSync() {
    final data = _syncBox.get(_pendingSyncKey);
    if (data == null) return null;

    if (data is Map) {
      // Cast is necessary because Hive checks types at runtime
      return SyncData.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> clearPendingSync() async {
    await _syncBox.delete(_pendingSyncKey);
  }
}

class SyncData {
  final String uid;
  final int totalTapsDelta;
  final List<OwnedUpgrade> purchasedUpgrades;
  final int currentBalance;
  final int timestamp; // Milliseconds since epoch

  SyncData({
    required this.uid,
    required this.totalTapsDelta,
    required this.purchasedUpgrades,
    required this.currentBalance,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'totalTapsDelta': totalTapsDelta,
      'purchasedUpgrades': purchasedUpgrades.map((u) => u.toJson()).toList(),
      'currentBalance': currentBalance,
      'timestamp': timestamp,
    };
  }

  factory SyncData.fromJson(Map<String, dynamic> json) {
    return SyncData(
      uid: json['uid'] as String,
      totalTapsDelta: json['totalTapsDelta'] as int? ?? 0,
      purchasedUpgrades:
          (json['purchasedUpgrades'] as List?)
              ?.map((e) => OwnedUpgrade.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      currentBalance: json['currentBalance'] as int? ?? 0,
      timestamp:
          json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  SyncData copyWith({
    String? uid,
    int? totalTapsDelta,
    List<OwnedUpgrade>? purchasedUpgrades,
    int? currentBalance,
    int? timestamp,
  }) {
    return SyncData(
      uid: uid ?? this.uid,
      totalTapsDelta: totalTapsDelta ?? this.totalTapsDelta,
      purchasedUpgrades: purchasedUpgrades ?? this.purchasedUpgrades,
      currentBalance: currentBalance ?? this.currentBalance,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
