import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Animated coin display widget
class CoinDisplay extends StatelessWidget {
  final int coins;
  final double? size;
  final bool showINR;
  final bool animate;
  final bool compact;

  const CoinDisplay({
    super.key,
    required this.coins,
    this.size,
    this.showINR = false,
    this.animate = true,
    this.compact = false,
  });

  String _formatCoins(int value) {
    if (compact) {
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
    }
    return NumberFormat('#,###').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 32;
    final inrValue = coins / 10000;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin icon
            Container(
              width: effectiveSize,
              height: effectiveSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.gold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/Coin.png',
                  width: effectiveSize * 0.9,
                  height: effectiveSize * 0.9,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    HugeIcons.strokeRoundedMoney03,
                    color: Colors.white,
                    size: effectiveSize * 0.7,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Coin amount
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _formatCoins(coins),
                key: ValueKey(coins),
                style: compact
                    ? AppTextStyles.statValue.copyWith(
                        color: AppColors.coinGold,
                        fontSize: effectiveSize * 0.6,
                      )
                    : AppTextStyles.coinBalance.copyWith(
                        fontSize: effectiveSize * 0.8,
                      ),
              ),
            ),
          ],
        ),
        if (showINR) ...[
          const SizedBox(height: 4),
          Text(
            '≈ ₹${inrValue.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      ],
    );
  }
}

/// Large animated coin for main screen
class LargeCoinDisplay extends StatelessWidget {
  final int coins;
  final bool showINR;

  const LargeCoinDisplay({super.key, required this.coins, this.showINR = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.coinGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coinGold.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'BALANCE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated coin icon
              Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.gold,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coinGold.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/Coin.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        HugeIcons.strokeRoundedMoney03,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
              const SizedBox(width: 12),
              // Coin amount
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  NumberFormat('#,###').format(coins),
                  key: ValueKey(coins),
                  style: AppTextStyles.coinBalanceLarge,
                ),
              ),
            ],
          ),
          if (showINR) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '≈ ₹${(coins / 10000).toStringAsFixed(2)}',
                style: AppTextStyles.inrAmount,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating coin animation for tap rewards
class FloatingCoin extends StatelessWidget {
  final int amount;
  final VoidCallback? onComplete;

  const FloatingCoin({super.key, required this.amount, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Text(
          '+$amount',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.coinGold,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: AppColors.coinGold.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        )
        .animate(onComplete: (_) => onComplete?.call())
        .moveY(
          begin: 0,
          end: -100,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeOut(delay: 500.ms, duration: 300.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.3, 1.3),
          duration: 800.ms,
        );
  }
}
