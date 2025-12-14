import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/gradient_button.dart';

/// Wallet screen for viewing balance and withdrawals
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final user = gameState.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final inrBalance = user.coinBalance / AppConstants.coinsPerINR;
    final canWithdraw = user.coinBalance >= AppConstants.minWithdrawalCoins;
    final minWithdrawalINR =
        AppConstants.minWithdrawalCoins / AppConstants.coinsPerINR;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Wallet', style: AppTextStyles.headlineLarge),

              const SizedBox(height: 24),

              // Main balance card
              Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.cardBackground, AppColors.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.coinGold.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coinGold.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL BALANCE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/Coin.png',
                              width: 56,
                              height: 56,
                              errorBuilder: (_, __, ___) => Icon(
                                HugeIcons.strokeRoundedMoney03,
                                color: AppColors.coinGold,
                                size: 56,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              NumberFormat('#,###').format(user.coinBalance),
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.coinGold,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '≈ ₹${inrBalance.toStringAsFixed(2)}',
                            style: AppTextStyles.inrAmountLarge,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Withdraw button
                        GradientButton(
                          text: canWithdraw
                              ? 'WITHDRAW'
                              : 'MIN ₹${minWithdrawalINR.round()} TO WITHDRAW',
                          width: double.infinity,
                          enabled: canWithdraw,
                          gradientColors: canWithdraw
                              ? AppColors.successGradient
                              : [AppColors.surface, AppColors.surfaceLight],
                          icon: HugeIcons.strokeRoundedWallet01,
                          onPressed: canWithdraw
                              ? () => _showWithdrawBottomSheet(context)
                              : null,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),

              const SizedBox(height: 24),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedTradeUp,
                      label: 'Lifetime Earned',
                      value: _formatCoins(user.lifetimeCoinsEarned),
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedShoppingCart01,
                      label: 'Total Spent',
                      value: _formatCoins(user.lifetimeCoinsSpent),
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Earnings breakdown
              Text('Earnings Breakdown', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),

              _BreakdownCard(
                items: [
                  _BreakdownItem(
                    icon: HugeIcons.strokeRoundedTap02,
                    label: 'Tap Mining',
                    value: '${user.totalTaps} taps',
                    subValue:
                        '~${_formatCoins((user.totalTaps * user.tapPower).round())} coins',
                  ),
                  _BreakdownItem(
                    icon: HugeIcons.strokeRoundedTime01,
                    label: 'Passive Mining',
                    value: _formatCoins(user.totalPassiveEarned),
                    subValue: '+${user.passiveRate.toStringAsFixed(1)}/sec',
                  ),
                  _BreakdownItem(
                    icon: HugeIcons.strokeRoundedChampion,
                    label: 'Achievements',
                    value:
                        '${gameState.achievements.where((a) => a.claimed).length} claimed',
                    subValue:
                        '${gameState.achievements.where((a) => a.unlocked && !a.claimed).length} pending',
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Conversion info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedInformationCircle,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conversion Rate',
                            style: AppTextStyles.titleSmall,
                          ),
                          Text(
                            '10,000 coins = ₹1 • Processing fee: ₹10',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###').format(coins);
  }

  void _showWithdrawBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _WithdrawBottomSheet(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<_BreakdownItem> items;

  const _BreakdownCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.value.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.label,
                            style: AppTextStyles.titleSmall,
                          ),
                          Text(
                            entry.value.subValue,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      entry.value.value,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: AppColors.cardBorder),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _BreakdownItem {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;

  _BreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
  });
}

class _WithdrawBottomSheet extends ConsumerStatefulWidget {
  const _WithdrawBottomSheet();

  @override
  ConsumerState<_WithdrawBottomSheet> createState() =>
      _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends ConsumerState<_WithdrawBottomSheet> {
  String _method = 'upi';
  final _upiController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _upiController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();

    final coins = user.coinBalance;
    final inrGross = coins / AppConstants.coinsPerINR;
    final processingFee =
        AppConstants.processingFeeCoins / AppConstants.coinsPerINR;
    final netAmount = inrGross - processingFee;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Withdraw Funds', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),

            // Amount summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount', style: AppTextStyles.bodyLarge),
                      Text(
                        '₹${inrGross.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Processing Fee', style: AppTextStyles.bodyLarge),
                      Text(
                        '-₹${processingFee.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('You Receive', style: AppTextStyles.titleMedium),
                      Text(
                        '₹${netAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Method selection
            Text('Payment Method', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MethodButton(
                    label: 'UPI',
                    icon: HugeIcons.strokeRoundedBank,
                    isSelected: _method == 'upi',
                    onTap: () => setState(() => _method = 'upi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodButton(
                    label: 'Bank',
                    icon: HugeIcons.strokeRoundedWallet01,
                    isSelected: _method == 'bank',
                    onTap: () => setState(() => _method = 'bank'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input fields
            if (_method == 'upi') ...[
              _InputField(
                controller: _upiController,
                label: 'UPI ID',
                hint: 'yourname@paytm',
                icon: HugeIcons.strokeRoundedMailAtSign01,
              ),
            ] else ...[
              _InputField(
                controller: _accountController,
                label: 'Account Number',
                hint: '1234567890',
                icon: HugeIcons.strokeRoundedCreditCard,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: _ifscController,
                label: 'IFSC Code',
                hint: 'SBIN0001234',
                icon: HugeIcons.strokeRoundedCode,
              ),
              const SizedBox(height: 16),
              _InputField(
                controller: _nameController,
                label: 'Account Holder Name',
                hint: 'John Doe',
                icon: HugeIcons.strokeRoundedUser,
              ),
            ],

            const SizedBox(height: 24),

            // Submit button
            GradientButton(
              text: 'REQUEST WITHDRAWAL',
              width: double.infinity,
              gradientColors: AppColors.successGradient,
              onPressed: () async {
                final success = await ref
                    .read(gameProvider.notifier)
                    .withdrawFunds(
                      coins, // Pass total coins to withdraw
                      _method,
                      _method == 'upi'
                          ? {'upiId': _upiController.text}
                          : {
                              'accountNumber': _accountController.text,
                              'ifsc': _ifscController.text,
                              'holderName': _nameController.text,
                            },
                    );

                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Withdrawal request submitted! Processing in 3-5 days.',
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Failed to submit withdrawal. Please try again.',
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
