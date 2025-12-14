import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/models/achievement_model.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/native_ad_widget.dart';

/// Rewards/Achievements screen
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _filter = 'all';
            break;
          case 1:
            _filter = 'unlocked';
            break;
          case 2:
            _filter = 'in_progress';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AchievementModel> _filterAchievements(
    List<AchievementModel> achievements,
  ) {
    switch (_filter) {
      case 'unlocked':
        return achievements.where((a) => a.unlocked).toList();
      case 'in_progress':
        return achievements.where((a) => !a.unlocked).toList();
      default:
        return achievements;
    }
  }

  Future<void> _claimAchievement(AchievementModel achievement) async {
    final success = await ref
        .read(gameProvider.notifier)
        .claimAchievement(achievement);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(HugeIcons.strokeRoundedStar, color: Colors.white),
              const SizedBox(width: 12),
              Text('Claimed ${achievement.rewardCoins} coins!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final achievements = _filterAchievements(gameState.achievements);
    final dailyBonus = ref.watch(dailyBonusProvider);

    final unlockedCount = gameState.achievements
        .where((a) => a.unlocked)
        .length;
    final totalCount = gameState.achievements.length;
    final claimableCount = gameState.achievements
        .where((a) => a.isClaimable)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Rewards', style: AppTextStyles.headlineLarge),
                  const Spacer(),
                  if (claimableCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedGift,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$claimableCount to claim',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Daily bonus card
            if (dailyBonus.canClaim)
              _DailyBonusCard(
                streak: dailyBonus.currentStreak,
                bonusAmount: dailyBonus.bonusAmount,
                onClaim: () =>
                    ref.read(gameProvider.notifier).claimDailyBonus(),
              ),

            // Progress summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.coinGold.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$unlockedCount / $totalCount',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.coinGold,
                            ),
                          ),
                          Text('Achievements', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.cardBorder,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${(unlockedCount / totalCount * 100).round()}%',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text('Complete', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppGradients.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: AppTextStyles.labelMedium,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Unlocked'),
                  Tab(text: 'In Progress'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Achievements list
            Expanded(
              child: achievements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedChampion,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No achievements here yet',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  : NativeAdListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      items: achievements,
                      adInterval: 5,
                      itemBuilder: (context, item, index) {
                        final achievement = item as AchievementModel;
                        return _AchievementCard(
                          achievement: achievement,
                          onClaim: () => _claimAchievement(achievement),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: index * 50),
                          duration: 300.ms,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBonusCard extends StatelessWidget {
  final int streak;
  final int bonusAmount;
  final VoidCallback onClaim;

  const _DailyBonusCard({
    required this.streak,
    required this.bonusAmount,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.coinGold.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🎁', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $streak Bonus!',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedMoney03,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+$bonusAmount coins',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClaim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'CLAIM',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.coinOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3));
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onClaim;

  const _AchievementCard({required this.achievement, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: achievement.unlocked ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: achievement.unlocked ? null : Colors.grey,
                  ),
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
                      Text(
                        achievement.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: achievement.unlocked
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      if (achievement.unlocked && achievement.claimed) ...[
                        const SizedBox(width: 8),
                        Icon(
                          HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(achievement.description, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  // Progress bar
                  if (!achievement.unlocked) ...[
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: achievement.progressPercentage,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(achievement.progressPercentage * 100).round()}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Reward / Claim button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedMoney03,
                      size: 16,
                      color: AppColors.coinGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.rewardCoins}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.coinGold,
                      ),
                    ),
                  ],
                ),
                if (achievement.isClaimable) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onClaim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'CLAIM',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
