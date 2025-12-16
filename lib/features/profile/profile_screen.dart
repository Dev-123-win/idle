import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../notifications/notifications_screen.dart';

/// Profile/Settings screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final user = gameState.user;
    final dailyBonus = ref.watch(dailyBonusProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Profile', style: AppTextStyles.headlineLarge),

              const SizedBox(height: 24),

              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : 'M',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.displayName,
                      style: AppTextStyles.headlineMedium,
                    ),
                    if (user.email != null) ...[
                      const SizedBox(height: 4),
                      Text(user.email!, style: AppTextStyles.bodyMedium),
                    ],
                    const SizedBox(height: 16),
                    // User ID
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedTag01,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ID: ${user.uid.substring(0, 8).toUpperCase()}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),

              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      value: '${dailyBonus.currentStreak}',
                      label: 'Day Streak',
                      color: AppColors.coinGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedTap02,
                      value: _formatNumber(user.totalTaps),
                      label: 'Total Taps',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedChampion,
                      value:
                          '${gameState.achievements.where((a) => a.unlocked).length}',
                      label: 'Achievements',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: HugeIcons.strokeRoundedTime01,
                      value: '${user.passiveRate.toStringAsFixed(1)}/s',
                      label: 'Passive Rate',
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Referral section
              _SectionHeader(title: 'Referral'),
              _ReferralCard(referralCode: user.referralCode),
              const SizedBox(height: 12),
              // Redeem UI
              if (user.referredBy == null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showRedeemDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Already have a code? Redeem it'),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Referred by: ${user.referredBy!}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Settings section
              _SectionHeader(title: 'Settings'),
              _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedNotification01,
                    title: 'Notifications',
                    subtitle: 'Enable push notifications',
                    isSwitch: true,
                    value: user.isNotificationsEnabled,
                    onChanged: (val) {
                      ref.read(gameProvider.notifier).toggleNotifications(val);
                    },
                    onTap: () {
                      // Navigate to notification history screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedSmartPhone01,
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrate on tap',
                    isSwitch: true,
                    value: user.isHapticEnabled,
                    onChanged: (val) {
                      ref.read(gameProvider.notifier).toggleHaptic(val);
                    },
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedVolumeHigh,
                    title: 'Sound Effects',
                    subtitle: 'Play sounds',
                    isSwitch: true,
                    value: false, // Default to false for now as not implemented
                    onChanged: (_) {},
                  ),
                  _SettingsItem(
                    icon: Icons.history,
                    title: 'Notification History',
                    subtitle: 'View recent alerts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Info section
              _SectionHeader(title: 'Information'),
              _SettingsCard(
                items: [
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedHelpCircle,
                    title: 'FAQ',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedFile01,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedSecurityCheck,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedCustomerSupport,
                    title: 'Contact Support',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    // Navigation handled by auth listener in main
                  },
                  icon: Icon(
                    HugeIcons.strokeRoundedLogout01,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Logout',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version
              Center(
                child: Text(
                  'CryptoMiner v1.0.0',
                  style: AppTextStyles.bodySmall,
                ),
              ),

              // Banner Ad
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: BannerAdWidget(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  void _showRedeemDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Redeem Referral Code',
          style: AppTextStyles.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a friend\'s code to get 5,000 coins!',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter Code',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim().toUpperCase();
              if (code.isEmpty) return;

              Navigator.pop(context); // Close dialog

              // Show loading if needed or snackbar

              final error = await ref
                  .read(gameProvider.notifier)
                  .redeemReferralCode(code);

              if (context.mounted) {
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Success! 5,000 coins added.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.titleMedium),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String referralCode;

  const _ReferralCard({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedUserGroup,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Referral Code', style: AppTextStyles.bodyMedium),
                    Text(
                      referralCode,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Referral code copied!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  HugeIcons.strokeRoundedCopy01,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(HugeIcons.strokeRoundedShare01),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Earn 20,000 coins when your friend earns 10,000 coins!',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsCard({required this.items});

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
          final item = entry.value;
          final isLast = entry.key == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                title: Text(item.title, style: AppTextStyles.titleSmall),
                subtitle: item.subtitle != null
                    ? Text(item.subtitle!, style: AppTextStyles.bodySmall)
                    : null,
                trailing: item.isSwitch
                    ? Switch(
                        value: item.value ?? false,
                        onChanged: item.onChanged,
                        activeThumbColor: AppColors.primary,
                      )
                    : Icon(
                        HugeIcons.strokeRoundedArrowRight01,
                        color: AppColors.textMuted,
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

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSwitch;
  final bool? value;
  final Function(bool)? onChanged;
  final VoidCallback? onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isSwitch = false,
    this.value,
    this.onChanged,
    this.onTap,
  });
}
