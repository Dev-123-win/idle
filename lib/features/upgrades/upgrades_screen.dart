import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/models/upgrade_model.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/upgrade_card.dart';
import '../../shared/widgets/coin_display.dart';
import '../../shared/widgets/native_ad_widget.dart';

/// Upgrades screen for purchasing tap and passive upgrades
class UpgradesScreen extends ConsumerStatefulWidget {
  const UpgradesScreen({super.key});

  @override
  ConsumerState<UpgradesScreen> createState() => _UpgradesScreenState();
}

class _UpgradesScreenState extends ConsumerState<UpgradesScreen>
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
            _filter = 'tap';
            break;
          case 2:
            _filter = 'passive';
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

  List<UpgradeModel> _filterUpgrades(List<UpgradeModel> upgrades) {
    switch (_filter) {
      case 'tap':
        return upgrades.where((u) => u.isTapUpgrade).toList();
      case 'passive':
        return upgrades.where((u) => u.isPassiveUpgrade).toList();
      default:
        return upgrades;
    }
  }

  Future<void> _handlePurchase(UpgradeModel upgrade) async {
    final success = await ref
        .read(gameProvider.notifier)
        .purchaseUpgrade(upgrade);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedCheckmarkCircle01,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text('${upgrade.name} upgraded to Lv.${upgrade.level + 1}!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedAlertCircle,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              const Text('Not enough coins!'),
            ],
          ),
          backgroundColor: AppColors.error,
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
    final upgrades = _filterUpgrades(gameState.upgrades);
    final balance = gameState.user?.coinBalance ?? 0;

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
                  Text('Upgrades', style: AppTextStyles.headlineLarge),
                  const Spacer(),
                  CoinDisplay(coins: balance, size: 24, compact: true),
                ],
              ),
            ),

            // Stats summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatSummary(
                        icon: HugeIcons.strokeRoundedTap02,
                        label: 'Tap Power',
                        value:
                            '+${gameState.user?.effectiveTapPower.toStringAsFixed(1) ?? '1.0'}',
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.cardBorder,
                    ),
                    Expanded(
                      child: _StatSummary(
                        icon: HugeIcons.strokeRoundedTime01,
                        label: 'Passive Rate',
                        value:
                            '+${gameState.user?.effectivePassiveRate.toStringAsFixed(1) ?? '0.5'}/s',
                        color: AppColors.secondary,
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
                  Tab(text: 'Tap Power'),
                  Tab(text: 'Passive'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Upgrades list
            Expanded(
              child: upgrades.isEmpty
                  ? Center(
                      child: Text(
                        'No upgrades available',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )
                  : NativeAdListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      items: upgrades,
                      adInterval: 4, // Show ad every 4 items
                      itemBuilder: (context, item, index) {
                        final upgrade = item as UpgradeModel;
                        return UpgradeCard(
                              upgrade: upgrade,
                              userBalance: balance,
                              onPurchase: () => _handlePurchase(upgrade),
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: index * 50),
                              duration: 300.ms,
                            )
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: Duration(milliseconds: index * 50),
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

class _StatSummary extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatSummary({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}
