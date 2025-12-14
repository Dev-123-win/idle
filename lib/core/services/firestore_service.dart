import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/upgrade_model.dart';
import '../models/achievement_model.dart';
import '../models/withdrawal_model.dart';

/// Service for Firestore database operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _withdrawalsCollection =>
      _firestore.collection('withdrawalRequests');

  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      _firestore.collection('transactions');

  CollectionReference<Map<String, dynamic>> get _globalConfigCollection =>
      _firestore.collection('globalConfig');

  // ===== USER OPERATIONS =====

  /// Create a new user document
  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toJson());
  }

  /// Get user by uid
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Update coin balance
  Future<void> updateCoinBalance(String uid, int newBalance) async {
    await _usersCollection.doc(uid).update({'coinBalance': newBalance});
  }

  /// Increment coin balance atomically
  Future<void> incrementCoinBalance(String uid, int amount) async {
    await _usersCollection.doc(uid).update({
      'coinBalance': FieldValue.increment(amount),
      'lifetimeCoinsEarned': FieldValue.increment(amount > 0 ? amount : 0),
    });
  }

  /// Decrement coin balance atomically
  Future<void> decrementCoinBalance(String uid, int amount) async {
    await _usersCollection.doc(uid).update({
      'coinBalance': FieldValue.increment(-amount),
      'lifetimeCoinsSpent': FieldValue.increment(amount),
    });
  }

  /// Update tap stats
  Future<void> updateTapStats(String uid, int totalTaps, int dailyTaps) async {
    await _usersCollection.doc(uid).update({
      'totalTaps': totalTaps,
      'dailyTaps': dailyTaps,
      'lastTapSync': FieldValue.serverTimestamp(),
    });
  }

  /// Update passive claim
  Future<void> updatePassiveClaim(
    String uid,
    int dailyPassiveEarned,
    int totalPassiveEarned,
  ) async {
    await _usersCollection.doc(uid).update({
      'lastPassiveClaim': FieldValue.serverTimestamp(),
      'dailyPassiveEarned': dailyPassiveEarned,
      'totalPassiveEarned': totalPassiveEarned,
    });
  }

  /// Update login streak
  Future<void> updateLoginStreak(
    String uid,
    int streak,
    String lastLoginDate,
  ) async {
    await _usersCollection.doc(uid).update({
      'loginStreak': streak,
      'lastLoginDate': lastLoginDate,
    });
  }

  /// Update tap power
  Future<void> updateTapPower(String uid, double tapPower) async {
    await _usersCollection.doc(uid).update({'tapPower': tapPower});
  }

  /// Update passive rate
  Future<void> updatePassiveRate(String uid, double passiveRate) async {
    await _usersCollection.doc(uid).update({'passiveRate': passiveRate});
  }

  // ===== UPGRADES OPERATIONS =====

  /// Save user upgrades
  Future<void> saveUpgrades(String uid, List<OwnedUpgrade> upgrades) async {
    await _usersCollection.doc(uid).update({
      'ownedUpgrades': upgrades.map((u) => u.toJson()).toList(),
    });
  }

  /// Get user upgrades
  Future<List<OwnedUpgrade>> getUpgrades(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final upgradesList = data['ownedUpgrades'] as List<dynamic>?;
      if (upgradesList != null) {
        return upgradesList
            .map((u) => OwnedUpgrade.fromJson(u as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  // ===== ACHIEVEMENTS OPERATIONS =====

  /// Save user achievements
  Future<void> saveAchievements(
    String uid,
    List<AchievementModel> achievements,
  ) async {
    await _usersCollection.doc(uid).update({
      'achievements': achievements.map((a) => a.toJson()).toList(),
    });
  }

  /// Get user achievements
  Future<List<AchievementModel>> getAchievements(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final achievementsList = data['achievements'] as List<dynamic>?;
      if (achievementsList != null) {
        return achievementsList
            .map((a) => AchievementModel.fromJson(a as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  // ===== WITHDRAWAL OPERATIONS =====

  /// Create withdrawal request
  Future<void> createWithdrawal(WithdrawalModel withdrawal) async {
    await _withdrawalsCollection
        .doc(withdrawal.requestId)
        .set(withdrawal.toJson());
  }

  /// Get user withdrawals
  Future<List<WithdrawalModel>> getUserWithdrawals(String uid) async {
    final query = await _withdrawalsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .get();

    return query.docs
        .map((doc) => WithdrawalModel.fromJson(doc.data()))
        .toList();
  }

  /// Stream user withdrawals
  Stream<List<WithdrawalModel>> streamUserWithdrawals(String uid) {
    return _withdrawalsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WithdrawalModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // ===== TRANSACTION OPERATIONS =====

  /// Create transaction record
  Future<void> createTransaction(TransactionModel transaction) async {
    await _transactionsCollection
        .doc(transaction.transactionId)
        .set(transaction.toJson());
  }

  /// Get user transactions
  Future<List<TransactionModel>> getUserTransactions(
    String uid, {
    int limit = 50,
  }) async {
    final query = await _transactionsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  /// Stream user transactions
  Stream<List<TransactionModel>> streamUserTransactions(
    String uid, {
    int limit = 20,
  }) {
    return _transactionsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // ===== REFERRAL OPERATIONS =====

  /// Check if referral code exists
  Future<bool> referralCodeExists(String code) async {
    final query = await _usersCollection
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Get user by referral code
  Future<UserModel?> getUserByReferralCode(String code) async {
    final query = await _usersCollection
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return UserModel.fromJson(query.docs.first.data());
    }
    return null;
  }

  /// Add referral
  Future<void> addReferral(
    String referrerUid,
    Map<String, dynamic> referralData,
  ) async {
    await _usersCollection.doc(referrerUid).update({
      'referrals': FieldValue.arrayUnion([referralData]),
    });
  }

  /// Get pending referrals (users who used my code and have > 1000 taps)
  Future<List<String>> getPendingReferrals(
    String myReferralCode,
    List<String> alreadyClaimedUids,
  ) async {
    // Note: Firestore 'not-in' or 'not-equal' has limitations.
    // It's safer to fetch active referrals and filter in memory if the list is small.
    // Or just fetch all referrals with > 1000 taps.

    final query = await _usersCollection
        .where('referredBy', isEqualTo: myReferralCode)
        .where('totalTaps', isGreaterThanOrEqualTo: 1000)
        .get();

    final activeUids = query.docs.map((d) => d.id).toList();

    // Filter out already claimed
    return activeUids
        .where((uid) => !alreadyClaimedUids.contains(uid))
        .toList();
  }

  // ===== GLOBAL CONFIG =====

  /// Get global config
  Future<Map<String, dynamic>?> getGlobalConfig() async {
    final doc = await _globalConfigCollection.doc('config').get();
    return doc.data();
  }

  /// Stream global config
  Stream<Map<String, dynamic>?> streamGlobalConfig() {
    return _globalConfigCollection
        .doc('config')
        .snapshots()
        .map((doc) => doc.data());
  }

  // ===== BATCH OPERATIONS =====

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    return await _firestore.runTransaction(transactionHandler);
  }

  /// Get batch writer
  WriteBatch getBatch() {
    return _firestore.batch();
  }
}
