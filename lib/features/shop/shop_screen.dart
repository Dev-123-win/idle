import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/services/iap_service.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/gradient_button.dart';

/// Shop screen for in-app purchases
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _iapService = IAPService();
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _iapService.initialize();
    _iapService.onPurchaseComplete = _handlePurchaseComplete;
    _iapService.onPurchaseError = _handlePurchaseError;
  }

  void _handlePurchaseComplete(
    String productId,
    String? paymentId,
    String? signature,
    String? orderId,
  ) async {
    setState(() {
      _purchasingId = null;
    });

    if (paymentId == null || signature == null) {
      _showError('Payment failed: Missing details');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Verify with backend
    _showSuccess('Verifying purchase...');

    // Using provider ref if we were in a Consumer/ConsumerStatefulWidget
    // Since this is just State, we might need to access providers or ApiService directly
    // Ideally update this class to ConsumerStatefulWidget, but for now we have _iapService.
    // We need ApiService access.
    final apiService = ApiService(); // Use singleton

    final isValid = await apiService.verifyPurchase(
      uid: user.uid,
      productId: productId,
      paymentId: paymentId,
      signature: signature,
      orderId: orderId ?? '',
    );

    if (isValid) {
      _showSuccess('Purchase verified! Granting rewards...');

      // Grant rewards via GameProvider
      await ref.read(gameProvider.notifier).grantPurchase(productId);

      _showSuccess('Rewards granted! 🎉');
    } else {
      _showError('Purchase validation failed!');
    }
  }

  void _handlePurchaseError(String error) {
    setState(() {
      _purchasingId = null;
    });
    _showError(error);
  }

  void _purchase(IAPProduct product) async {
    setState(() {
      _purchasingId = product.id;
    });

    await _iapService.purchase(product.id);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _iapService.getProducts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Shop', style: AppTextStyles.headlineSmall),
        actions: [
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                _showError('Please login to restore purchases');
                return;
              }

              _showSuccess('Checking for previous purchases...');

              try {
                final restored = await _iapService.restorePurchases(user.uid);
                if (restored.isEmpty) {
                  _showSuccess('No active purchases found to restore');
                } else {
                  _showSuccess('Restored: ${restored.join(", ")}');
                  // Refresh game state or user provider if needed here
                  // ref.refresh(gameProvider);
                }
              } catch (e) {
                _showError('Failed to restore: $e');
              }
            },
            child: Text(
              'Restore',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(
                product: products[index],
                isLoading: _purchasingId == products[index].id,
                onPurchase: () => _purchase(products[index]),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 100))
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final IAPProduct product;
  final bool isLoading;
  final VoidCallback onPurchase;

  const _ProductCard({
    required this.product,
    required this.isLoading,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscription = product.type == IAPProductType.subscription;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            product.isPopular
                ? AppColors.coinGold.withValues(alpha: 0.05)
                : AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: product.isPopular
              ? AppColors.coinGold.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: product.isPopular ? 2 : 1,
        ),
        boxShadow: product.isPopular
            ? [
                BoxShadow(
                  color: AppColors.coinGold.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Popular badge
          if (product.isPopular)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          product.badge ?? '💎',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${product.priceINR}',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (isSubscription)
                                Text('/month', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(product.description, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 16),

                // Features
                if (product.features != null)
                  ...product.features!.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Buy button
                GradientButton(
                  text: isSubscription ? 'SUBSCRIBE' : 'BUY NOW',
                  width: double.infinity,
                  isLoading: isLoading,
                  gradientColors: product.isPopular
                      ? [AppColors.coinOrange, AppColors.coinGold]
                      : [AppColors.primary, AppColors.secondary],
                  icon: isSubscription ? Icons.star : Icons.shopping_cart,
                  onPressed: onPurchase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
