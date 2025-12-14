import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

/// Email verification screen for withdrawal eligibility
class EmailVerificationScreen extends StatefulWidget {
  final String? currentEmail;
  final VoidCallback onVerified;
  final VoidCallback? onSkip;

  const EmailVerificationScreen({
    super.key,
    this.currentEmail,
    required this.onVerified,
    this.onSkip,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _linkSent = false;
  String? _error;
  int _resendTimer = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.currentEmail != null) {
      _emailController.text = widget.currentEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendVerificationLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'User not logged in',
        );
      }

      // Update email if different
      if (user.email != email) {
        await user.verifyBeforeUpdateEmail(email);
      } else {
        await user.sendEmailVerification();
      }

      setState(() {
        _isLoading = false;
        _linkSent = true;
        _resendTimer = 60;
      });

      _startResendTimer();
      _showSuccess('Verification link sent to $email');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to send verification link';
      });
    }
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        setState(() => _isLoading = false);
        _showSuccess('Email verified successfully!');
        widget.onVerified();
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Email not verified yet. Please check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error checking status: $e';
      });
    }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onSkip != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onSkip,
              )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              AppColors.info.withValues(alpha: 0.15),
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

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.info.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: AppColors.info,
                  ),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 32),

                Text(
                  _linkSent ? 'Check Your Inbox' : 'Verify Your Email',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  _linkSent
                      ? 'We sent a verification link to\n${_emailController.text}'
                      : 'Verify your email to enable withdrawals',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                if (!_linkSent) ...[
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'email@example.com',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textMuted,
                        ),
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tap the link in the email we sent you, then tap the button below.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        if (_resendTimer > 0)
                          Text(
                            'Resend link in ${_resendTimer}s',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _sendVerificationLink,
                            child: Text(
                              'Resend Link',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _linkSent = false;
                        _resendTimer = 0;
                        _timer?.cancel();
                      });
                    },
                    child: Text(
                      'Change Email',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 40),

                GradientButton(
                  text: _linkSent ? 'I HAVE VERIFIED' : 'SEND LINK',
                  width: double.infinity,
                  isLoading: _isLoading,
                  gradientColors: [AppColors.info, AppColors.primary],
                  icon: _linkSent ? Icons.check_circle_outline : Icons.send,
                  onPressed: _linkSent
                      ? _checkVerificationStatus
                      : _sendVerificationLink,
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
