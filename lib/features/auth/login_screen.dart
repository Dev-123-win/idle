import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

/// Login screen with Google and Phone options
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _showPhoneLogin = false;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    // Simulate login for demo - replace with actual Firebase Auth
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    widget.onLoginSuccess?.call();
  }

  void _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber:
            '+91${_phoneController.text}', // Assuming +91, can be dynamic
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android
          await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() => _isLoading = false);
          widget.onLoginSuccess?.call();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _verificationId = verificationId;
          });
          _showSuccess('OTP sent to ${_phoneController.text}');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error starting verification: $e');
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showError('Please enter valid 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showError('Please request OTP first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => _isLoading = false);
      widget.onLoginSuccess?.call();
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message ?? 'Invalid OTP');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Verification failed: $e');
    }
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
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/Coin.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.diamond,
                        size: 56,
                        color: Colors.white,
                      ),
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
                Text(
                  'CryptoMiner',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 8),

                Text(
                  'Tap. Earn. Withdraw.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 60),

                // Login options
                if (!_showPhoneLogin) ...[
                  // Google Sign In
                  _SocialButton(
                    text: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    color: Colors.white,
                    backgroundColor: AppColors.cardBackground,
                    isLoading: _isLoading,
                    onPressed: _handleGoogleLogin,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Phone login button
                  _SocialButton(
                    text: 'Continue with Phone',
                    icon: Icons.phone_android,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    onPressed: () => setState(() => _showPhoneLogin = true),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.cardBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: AppTextStyles.bodyMedium),
                      ),
                      Expanded(child: Divider(color: AppColors.cardBorder)),
                    ],
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 32),

                  // Skip for now (demo mode)
                  TextButton(
                    onPressed: widget.onLoginSuccess,
                    child: Text(
                      'Skip for now (Demo Mode)',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ] else ...[
                  // Phone login form
                  _buildPhoneLoginForm(),
                ],

                const SizedBox(height: 60),

                // Terms and Privacy
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodySmall,
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        TextButton.icon(
          onPressed: () => setState(() {
            _showPhoneLogin = false;
            _otpSent = false;
            _phoneController.clear();
            _otpController.clear();
          }),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
        ),

        const SizedBox(height: 16),

        Text(
          _otpSent ? 'Enter OTP' : 'Enter Phone Number',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          _otpSent
              ? 'We sent a 6-digit code to ${_phoneController.text}'
              : 'We\'ll send you a verification code',
          style: AppTextStyles.bodyMedium,
        ),

        const SizedBox(height: 24),

        if (!_otpSent) ...[
          // Phone input
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text('+91', style: AppTextStyles.titleMedium),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.titleMedium,
                    decoration: InputDecoration(
                      hintText: '9876543210',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // OTP input
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ],

        const SizedBox(height: 24),

        GradientButton(
          text: _otpSent ? 'VERIFY OTP' : 'SEND OTP',
          width: double.infinity,
          isLoading: _isLoading,
          onPressed: _otpSent ? _verifyOtp : _handlePhoneLogin,
        ),

        if (_otpSent) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() => _otpSent = false);
              },
              child: Text(
                'Resend OTP',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.cardBorder),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28),
                  const SizedBox(width: 12),
                  Text(text, style: AppTextStyles.labelLarge),
                ],
              ),
      ),
    );
  }
}
