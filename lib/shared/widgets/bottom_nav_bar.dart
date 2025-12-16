import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Custom bottom navigation bar with neon glow effect
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: HugeIcons.strokeRoundedTap02,
                label: 'Mine',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                color: AppColors.primary,
              ),
              _NavItem(
                icon: HugeIcons.strokeRoundedRocket,
                label: 'Upgrades',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                color: AppColors.secondary,
              ),
              _NavItem(
                icon: HugeIcons.strokeRoundedWallet01,
                label: 'Wallet',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                color: AppColors.success,
              ),
              _NavItem(
                icon: HugeIcons.strokeRoundedChampion,
                label: 'Rewards',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
                color: AppColors.coinGold,
              ),
              _NavItem(
                icon: HugeIcons.strokeRoundedShoppingBag01,
                label: 'Shop',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
                color: AppColors.coinOrange,
              ),
              _NavItem(
                icon: HugeIcons.strokeRoundedUser,
                label: 'Profile',
                isSelected: currentIndex == 5,
                onTap: () => onTap(5),
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textMuted,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? color : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
              child: Text(label),
            ),
            // Animated indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// App header with balance and notification
class AppHeader extends StatelessWidget {
  final int coinBalance;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;

  const AppHeader({
    super.key,
    required this.coinBalance,
    this.onNotificationTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo / App name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedDiamond01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'CryptoMiner',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.coinGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/Coin.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => Icon(
                    HugeIcons.strokeRoundedMoney03,
                    color: AppColors.coinGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatBalance(coinBalance),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.coinGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notification button
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      HugeIcons.strokeRoundedNotification01,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  // Notification dot
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBalance(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}
