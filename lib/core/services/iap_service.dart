import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// Service for handling in-app purchases via Razorpay
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  // TODO: Replace with your actual Razorpay Key ID from Dashboard -> Settings -> API Keys
  static const String _razorpayKey = 'rzp_test_Rp3pLBBYsxL9Gz';

  late Razorpay _razorpay;
  bool _initialized = false;
  String? _pendingProductId;

  // Callback for purchase completion
  Function(
    String productId,
    String? paymentId,
    String? signature,
    String? orderId,
  )?
  onPurchaseComplete;
  Function(String error)? onPurchaseError;

  /// Initialize Razorpay
  Future<void> initialize() async {
    if (_initialized) return;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _initialized = true;
    debugPrint('IAP Service initialized');
  }

  /// Get all available products
  List<IAPProduct> getProducts() {
    return _products;
  }

  /// Get product by ID
  IAPProduct? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Start purchase flow
  Future<void> purchase(
    String productId, {
    String? email,
    String? phoneNumber,
  }) async {
    final product = getProduct(productId);
    if (product == null) {
      onPurchaseError?.call('Product not found');
      return;
    }

    _pendingProductId = productId;
    debugPrint('Starting purchase for: ${product.name}');

    var options = {
      'key': _razorpayKey,
      'amount': product.priceINR * 100, // Amount in paise
      'name': 'CryptoMiner',
      'description': product.name,
      'prefill': {'contact': phoneNumber ?? '', 'email': email ?? ''},
      'notes': {'productId': productId, 'appId': 'com.supreet.idleminer'},
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting Razorpay checkout: $e');
      _pendingProductId = null;
      onPurchaseError?.call('Found error: $e');
    }
  }

  /// Restore previous purchases
  Future<List<String>> restorePurchases(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final List<String> restoredIds = [];

      if (data['adsRemoved'] == true) {
        restoredIds.add(IAPProducts.removeAds);
      }

      if (data['hasPassiveUpgrade'] == true) {
        restoredIds.add(IAPProducts.passiveBooster);
      }

      final vipUntil = data['vipUntil'] != null
          ? (data['vipUntil'] is Timestamp
                ? (data['vipUntil'] as Timestamp).toDate()
                : DateTime.tryParse(data['vipUntil'].toString()))
          : null;

      if (vipUntil != null && vipUntil.isAfter(DateTime.now())) {
        restoredIds.add(IAPProducts.vipMonthly);
      }

      // Check for active boosts if tracked in user model lists or similar
      // For now, these operate as flags

      return restoredIds;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return [];
    }
  }

  /// Check if user has removed ads
  Future<bool> hasRemovedAds(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) return false;
      return (doc.data() as Map<String, dynamic>)['adsRemoved'] == true;
    } catch (e) {
      debugPrint('Error checking ads removed: $e');
      return false;
    }
  }

  /// Check if user has passive booster
  Future<bool> hasPassiveBooster(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) return false;
      return (doc.data() as Map<String, dynamic>)['hasPassiveUpgrade'] == true;
    } catch (e) {
      debugPrint('Error checking passive booster: $e');
      return false;
    }
  }

  /// Check if user is VIP
  Future<bool> isVIP(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final vipUntil = data['vipUntil'] != null
          ? (data['vipUntil'] is Timestamp
                ? (data['vipUntil'] as Timestamp).toDate()
                : DateTime.tryParse(data['vipUntil'].toString()))
          : null;

      return vipUntil != null && vipUntil.isAfter(DateTime.now());
    } catch (e) {
      debugPrint('Error checking VIP status: $e');
      return false;
    }
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');

    // Grant purchased item
    if (_pendingProductId != null) {
      onPurchaseComplete?.call(
        _pendingProductId!,
        response.paymentId,
        response.signature,
        response.orderId,
      );
      _pendingProductId = null;
    } else {
      // In a real app we might query backend to see recent orders
      onPurchaseComplete?.call(
        'latest_product',
        response.paymentId,
        response.signature,
        response.orderId,
      );
    }
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    _pendingProductId = null;
    onPurchaseError?.call(response.message ?? 'Payment failed');
  }

  /// Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  /// Dispose
  void dispose() {
    _razorpay.clear();
  }
}

/// IAP Product model
class IAPProduct {
  final String id;
  final String name;
  final String description;
  final int priceINR;
  final IAPProductType type;
  final int? coins;
  final int? boostMultiplier;
  final int? durationDays;
  final List<String>? features;
  final String? badge;
  final bool isPopular;

  const IAPProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.priceINR,
    required this.type,
    this.coins,
    this.boostMultiplier,
    this.durationDays,
    this.features,
    this.badge,
    this.isPopular = false,
  });
}

enum IAPProductType { oneTime, subscription, consumable }

/// Available products
final List<IAPProduct> _products = [
  // Remove Ads
  const IAPProduct(
    id: IAPProducts.removeAds,
    name: 'Remove Ads Forever',
    description: 'Enjoy an ad-free mining experience forever!',
    priceINR: 299,
    type: IAPProductType.oneTime,
    features: [
      'No banner ads',
      'No interstitial ads',
      'No app open ads',
      'Still earn from rewarded ads',
    ],
    badge: '🚫',
  ),

  // 2x Boost
  const IAPProduct(
    id: IAPProducts.boost2x7days,
    name: '2x Boost',
    description: 'Double your tap and passive earnings for 7 days!',
    priceINR: 99,
    type: IAPProductType.oneTime,
    boostMultiplier: 2,
    durationDays: 7,
    features: ['2x tap power', '2x passive mining', 'Lasts 7 days'],
    badge: '2️⃣',
    isPopular: true,
  ),

  // 5x Boost
  const IAPProduct(
    id: IAPProducts.boost5x7days,
    name: '5x Boost',
    description: '5x your earnings for 7 days - maximum power!',
    priceINR: 199,
    type: IAPProductType.oneTime,
    boostMultiplier: 5,
    durationDays: 7,
    features: ['5x tap power', '5x passive mining', 'Lasts 7 days'],
    badge: '5️⃣',
  ),

  // Starter Pack
  const IAPProduct(
    id: IAPProducts.starterPack,
    name: 'Starter Pack',
    description: 'Get a head start with coins and unlocked upgrades!',
    priceINR: 149,
    type: IAPProductType.consumable,
    coins: 500000,
    features: ['500,000 coins', 'Basic upgrades unlocked', 'One-time purchase'],
    badge: '🎁',
  ),

  // Growth Pack
  const IAPProduct(
    id: IAPProducts.growthPack,
    name: 'Growth Pack',
    description: 'Massive coin boost to accelerate your progress!',
    priceINR: 349,
    type: IAPProductType.consumable,
    coins: 2000000,
    features: [
      '2,000,000 coins',
      'Tier 1-3 upgrades unlocked',
      'One-time purchase',
    ],
    badge: '📈',
  ),

  // VIP Monthly
  const IAPProduct(
    id: IAPProducts.vipMonthly,
    name: 'VIP Monthly',
    description: 'Ultimate premium experience with exclusive benefits!',
    priceINR: 199,
    type: IAPProductType.subscription,
    durationDays: 30,
    features: [
      'Ad-free experience',
      '2x passive earnings',
      'Exclusive VIP badge',
      'Priority withdrawal (1-2 days)',
      'Exclusive support channel',
    ],
    badge: '👑',
    isPopular: true,
  ),

  // Passive Manager (New)
  const IAPProduct(
    id: IAPProducts.passiveBooster,
    name: 'Passive Manager',
    description:
        'Unlock 6h offline earnings & 5x daily passive cap + 0.5/s Base Rate!',
    priceINR: 149,
    type: IAPProductType.oneTime,
    features: [
      '6 hours max offline time',
      '50,000 daily passive cap',
      '0.5 coins/sec base rate',
      'One-time purchase',
    ],
    badge: '⚡',
  ),
];
