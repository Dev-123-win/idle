import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/models/upgrade_model.dart';
import 'coin_display.dart';

/// Upgrade card widget
class UpgradeCard extends StatelessWidget {
  final UpgradeModel upgrade;
  final int userBalance;
  final VoidCallback? onPurchase;

  const UpgradeCard({
    super.key,
    required this.upgrade,
    required this.userBalance,
    this.onPurchase,
  });

  bool get canAfford => userBalance >= upgrade.currentCost;
  bool get isOwned => upgrade.level > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned
              ? upgrade.isTapUpgrade
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.secondary.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: isOwned ? 1.5 : 1,
        ),
        boxShadow: isOwned
            ? [
                BoxShadow(
                  color:
                      (upgrade.isTapUpgrade
                              ? AppColors.primary
                              : AppColors.secondary)
                          .withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPurchase,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: upgrade.isTapUpgrade
                          ? [
                              AppColors.primary.withValues(alpha: 0.2),
                              AppColors.primary.withValues(alpha: 0.1),
                            ]
                          : [
                              AppColors.secondary.withValues(alpha: 0.2),
                              AppColors.secondary.withValues(alpha: 0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      upgrade.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(upgrade.name, style: AppTextStyles.upgradeTitle),
                          const SizedBox(width: 8),
                          if (isOwned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lv.${upgrade.level}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOwned
                            ? upgrade.description
                            : upgrade.nextLevelDescription,
                        style: AppTextStyles.upgradeEffect,
                      ),
                      const SizedBox(height: 8),
                      // Cost
                      Row(
                        children: [
                          CoinDisplay(
                            coins: upgrade.currentCost,
                            size: 18,
                            compact: true,
                          ),
                          const Spacer(),
                          // Buy button
                          if (!upgrade.isMaxLevel)
                            _buildBuyButton()
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'MAX',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyButton() {
    if (canAfford) {
      return GestureDetector(
        onTap: onPurchase,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            isOwned ? 'UPGRADE' : 'BUY',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              HugeIcons.strokeRoundedLockKey,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              isOwned ? 'UPGRADE' : 'BUY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
  }
}

/// Stat chip for displaying stats
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveColor, size: 20),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(color: effectiveColor),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

/// Progress bar for tap counter
class TapProgressBar extends StatelessWidget {
  final int currentTaps;
  final int maxTaps;
  final bool canClaim;

  const TapProgressBar({
    super.key,
    required this.currentTaps,
    required this.maxTaps,
    this.canClaim = false,
  });

  double get progress => currentTaps / maxTaps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canClaim ? AppColors.success : AppColors.cardBorder,
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAP PROGRESS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$currentTaps / $maxTaps',
                style: AppTextStyles.titleMedium.copyWith(
                  color: canClaim ? AppColors.success : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 12,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: canClaim
                          ? AppGradients.success
                          : AppGradients.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (canClaim ? AppColors.success : AppColors.primary)
                                  .withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (canClaim) ...[
            const SizedBox(height: 12),
            Text(
                  '🎉 Ready to claim!',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1500.ms,
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
          ],
        ],
      ),
    );
  }
}
