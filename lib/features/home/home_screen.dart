import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/game_provider.dart';
import '../../core/services/admob_service.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../mining/mining_screen.dart';
import '../upgrades/upgrades_screen.dart';
import '../wallet/wallet_screen.dart';
import '../rewards/rewards_screen.dart';
import '../shop/shop_screen.dart';
import '../profile/profile_screen.dart';
import '../../shared/widgets/loading_overlay.dart';

/// Main home screen with bottom navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    // Initialize game with authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;
      if (user != null) {
        ref.read(gameProvider.notifier).initializeGame(user.uid);
      } else {
        // Fallback or redirect if no user found (shouldn't happen if guarded)
        debugPrint('No authenticated user found in HomeScreen');
        // Optionally redirect to login if this happens
        // ref.read(gameProvider.notifier).initializeDemo(); // Only for DEV
      }
    });
    // Preload ads
    _adMobService.preloadAds();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleClaimRequired() {
    final user = ref.read(gameProvider).user;

    // Skip ad if purchased removal
    if (user?.adsRemoved == true) {
      ref
          .read(gameProvider.notifier)
          .claimTapRewards(); // Or claimPassive if needed?

      // Note: Currently claimTapRewards handles tap claims.
      // But _PassiveBanner calls this same callback.
      // We might need to differentiate between Tap Claim and Passive Claim?
      // _PassiveBanner calls widget.onClaimRequired.
      // MiningScreen calls widget.onClaimRequired for BOTH Tap Progress Claim AND Passive Claim.
      // BUT GameNotifier has separate methods: claimTapRewards() and claimPassiveEarnings().

      // PROBLEM: MiningScreen uses same callback for both.
      // I should either split the callback or handle both claims in one go.

      // Let's claim both for convenience.
      ref.read(gameProvider.notifier).claimTapRewards();
      ref.read(gameProvider.notifier).claimPassiveEarnings();

      _showClaimSuccess();
      return;
    }

    // Show rewarded ad then claim
    if (_adMobService.isRewardedReady) {
      _adMobService.showRewarded(
        onRewarded: (amount) {
          ref.read(gameProvider.notifier).claimTapRewards();
          ref.read(gameProvider.notifier).claimPassiveEarnings();
          _showClaimSuccess();
        },
        onDismissed: () {},
        onFailed: () {
          // Grant reward anyway (user-friendly)
          ref.read(gameProvider.notifier).claimTapRewards();
          ref.read(gameProvider.notifier).claimPassiveEarnings();
          _showClaimSuccess();
        },
      );
    } else {
      // No ad available, claim anyway
      ref.read(gameProvider.notifier).claimTapRewards();
      ref.read(gameProvider.notifier).claimPassiveEarnings();
      _showClaimSuccess();
    }
  }

  void _showClaimSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(HugeIcons.strokeRoundedStar, color: Colors.white),
            SizedBox(width: 12),
            Text('Coins claimed successfully! 🎉'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for achievement notifications
    final newAchievement = ref.watch(gameProvider).newlyUnlockedAchievement;

    if (newAchievement != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAchievementPopup(newAchievement.name, newAchievement.rewardCoins);
        ref.read(gameProvider.notifier).clearAchievementNotification();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              MiningScreen(onClaimRequired: _handleClaimRequired),
              const UpgradesScreen(),
              const WalletScreen(),
              const RewardsScreen(),
              const ShopScreen(),
              const ProfileScreen(),
            ],
          ),
          // Global Loading Guard
          if (ref.watch(gameProvider).isLoading)
            const LoadingOverlay(message: 'Processing Transaction...'),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  void _showAchievementPopup(String name, int reward) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.coinGold.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.coinGold.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedChampion,
                  size: 48,
                  color: Colors.white,
                ),
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              const Text(
                '🎉 Achievement Unlocked! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coinGold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      HugeIcons.strokeRoundedMoney03,
                      color: AppColors.coinGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+$reward coins',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.coinGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
