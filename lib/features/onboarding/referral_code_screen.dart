import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

/// Referral code entry screen shown during signup
class ReferralCodeScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final Function(String code) onApply;

  const ReferralCodeScreen({
    super.key,
    required this.onSkip,
    required this.onApply,
  });

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validateAndApply() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() => _error = 'Please enter a referral code');
      return;
    }

    if (code.length < 6) {
      setState(() => _error = 'Referral code must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Check if code exists in Firestore
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Invalid referral code';
        });
        return;
      }

      setState(() => _isLoading = false);
      widget.onApply(code);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error validating code: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              AppColors.secondary.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: widget.onSkip,
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.textMuted,
                ),

                const Spacer(),

                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🎁', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 32),

                // Title
                Center(
                  child: Text(
                    'Have a Referral Code?',
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Enter your friend\'s code to get 5,000 bonus coins!',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // Code input
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _error != null
                          ? AppColors.error
                          : AppColors.cardBorder,
                      width: _error != null ? 2 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'MINE12345',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      hintStyle: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 4,
                      ),
                    ),
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    onChanged: (_) {
                      if (_error != null) {
                        setState(() => _error = null);
                      }
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Bonus preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.card_giftcard, color: AppColors.success),
                      const SizedBox(width: 12),
                      Text(
                        'You\'ll receive: ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Image.asset(
                        'assets/Coin.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.monetization_on,
                          color: AppColors.coinGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+5,000',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.coinGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(),

                // Apply button
                GradientButton(
                  text: 'APPLY CODE',
                  width: double.infinity,
                  isLoading: _isLoading,
                  gradientColors: [AppColors.secondary, AppColors.primary],
                  icon: Icons.check_circle,
                  onPressed: _validateAndApply,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                // Skip button
                Center(
                  child: TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
