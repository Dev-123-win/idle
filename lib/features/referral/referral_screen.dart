import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/gradient_button.dart';

/// Referral screen showing user's referral code and referrals list (S12)
class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final referralCode = gameState.user?.referralCode ?? 'LOADING...';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Referral Program', style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral Code Card
            _ReferralCodeCard(
              referralCode: referralCode,
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Share Buttons
            _ShareButtons(
              referralCode: referralCode,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // How It Works Section
            _HowItWorksSection()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Your Referrals List
            Text('Your Referrals', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            _ReferralsList(
              referralCode: referralCode,
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  final String referralCode;

  const _ReferralCodeCard({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Referral Code',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  referralCode,
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _copyCode(context),
                  icon: Icon(Icons.copy, color: AppColors.primary),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share this code & earn 20,000 coins\nfor every active referral!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Referral code copied!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ShareButtons extends StatelessWidget {
  final String referralCode;

  const _ShareButtons({required this.referralCode});

  String get _shareMessage =>
      '🎮 Join CryptoMiner and earn real money!\n\n'
      'Use my referral code: $referralCode\n\n'
      '💰 Get 5,000 coins bonus on signup!\n'
      '📱 Download now: https://play.google.com/store/apps/details?id=com.cryptominer.app';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share via', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ShareButton(
                icon: Icons.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareGeneric(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShareButton(
                icon: Icons.send,
                label: 'Telegram',
                color: const Color(0xFF0088CC),
                onTap: () => _shareGeneric(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShareButton(
                icon: Icons.sms,
                label: 'SMS',
                color: AppColors.secondary,
                onTap: () => _shareGeneric(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GradientButton(
          text: 'Share via Other Apps',
          icon: Icons.share,
          width: double.infinity,
          onPressed: () => _shareGeneric(),
        ),
      ],
    );
  }

  void _shareGeneric() {
    Share.share(_shareMessage, subject: 'Join CryptoMiner!');
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 8),
              Text('How It Works', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          const _HowItWorksStep(
            number: '1',
            title: 'Share Your Code',
            description: 'Send your referral code to friends',
          ),
          const _HowItWorksStep(
            number: '2',
            title: 'Friend Signs Up',
            description: 'They enter your code during registration',
          ),
          const _HowItWorksStep(
            number: '3',
            title: 'Friend Plays',
            description: 'They earn 10,000 coins through gameplay',
          ),
          const _HowItWorksStep(
            number: '4',
            title: 'You Earn!',
            description: 'Get 20,000 coins when they reach 10K',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isLast;

  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferralsList extends StatelessWidget {
  final String referralCode;

  const _ReferralsList({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    if (referralCode == 'LOADING...' || referralCode.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('referredBy', isEqualTo: referralCode)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading referrals: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'No referrals yet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your code to start earning!',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['displayName'] as String? ?? 'User';
            final totalTaps = data['totalTaps'] as int? ?? 0;
            // Determine status based on activity (e.g. total taps > 1000 or recent login)
            // For now, let's say active if totalTaps > 1000
            final status = totalTaps >= 1000 ? 'active' : 'pending';
            final joinedAt = data['createdAt'] != null
                ? (data['createdAt'] is Timestamp
                      ? (data['createdAt'] as Timestamp).toDate()
                      : DateTime.tryParse(data['createdAt'].toString()))
                : null;

            return _ReferralCard(
              name: name,
              status: status,
              joinedAt: joinedAt,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String name;
  final String status;
  final DateTime? joinedAt;

  const _ReferralCard({
    required this.name,
    required this.status,
    this.joinedAt,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isActive ? AppGradients.success : AppGradients.gold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall),
                Text(
                  joinedAt != null ? 'Joined recently' : 'Recently joined',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.success : AppColors.coinGold)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : 'Pending',
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.success : AppColors.coinGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
