import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/gradient_button.dart';

/// Daily bonus popup dialog
class DailyBonusPopup extends StatefulWidget {
  final int currentStreak;
  final int bonusAmount;
  final VoidCallback onClaim;
  final VoidCallback onWatchAd;
  final VoidCallback onClose;

  const DailyBonusPopup({
    super.key,
    required this.currentStreak,
    required this.bonusAmount,
    required this.onClaim,
    required this.onWatchAd,
    required this.onClose,
  });

  @override
  State<DailyBonusPopup> createState() => _DailyBonusPopupState();
}

class _DailyBonusPopupState extends State<DailyBonusPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
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
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Gift icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 48)),
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Daily Bonus!',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.coinGold,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            // Streak info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Day ${widget.currentStreak} Streak!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Days row
            _buildDaysRow(),

            const SizedBox(height: 24),

            // Reward amount
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Coin.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.monetization_on,
                        color: AppColors.coinGold,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '+${widget.bonusAmount}',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.coinGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            // Claim button
            GradientButton(
              text: 'CLAIM BONUS',
              width: double.infinity,
              gradientColors: [AppColors.coinOrange, AppColors.coinGold],
              icon: Icons.redeem,
              onPressed: widget.onClaim,
            ),

            const SizedBox(height: 12),

            // Watch ad for 2x
            GestureDetector(
              onTap: widget.onWatchAd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Watch Ad for 2x Bonus!',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isCurrentDay = day == widget.currentStreak;
        final isPastDay = day < widget.currentStreak;
        final bonus = AppConstants.dailyBonusAmounts[day] ?? 500;

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isPastDay
                    ? AppColors.success.withValues(alpha: 0.3)
                    : isCurrentDay
                    ? AppColors.coinGold
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentDay
                      ? AppColors.coinGold
                      : isPastDay
                      ? AppColors.success
                      : AppColors.cardBorder,
                  width: isCurrentDay ? 3 : 1,
                ),
                boxShadow: isCurrentDay
                    ? [
                        BoxShadow(
                          color: AppColors.coinGold.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isPastDay
                    ? const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 18,
                      )
                    : Text(
                        '$day',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isCurrentDay
                              ? Colors.white
                              : AppColors.textMuted,
                          fontWeight: isCurrentDay
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${bonus ~/ 1000}K',
              style: AppTextStyles.labelSmall.copyWith(
                color: isCurrentDay ? AppColors.coinGold : AppColors.textMuted,
                fontSize: 9,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Show daily bonus popup
void showDailyBonusPopup(
  BuildContext context, {
  required int currentStreak,
  required int bonusAmount,
  required VoidCallback onClaim,
  required VoidCallback onWatchAd,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DailyBonusPopup(
      currentStreak: currentStreak,
      bonusAmount: bonusAmount,
      onClaim: () {
        Navigator.pop(context);
        onClaim();
      },
      onWatchAd: () {
        Navigator.pop(context);
        onWatchAd();
      },
      onClose: () => Navigator.pop(context),
    ),
  );
}
