import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/game_provider.dart';
import '../../shared/widgets/coin_display.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/upgrade_card.dart';
import '../../shared/widgets/coin_tap_animator.dart';

/// Main mining screen - primary game interface
class MiningScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClaimRequired;

  const MiningScreen({super.key, this.onClaimRequired});

  @override
  ConsumerState<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends ConsumerState<MiningScreen>
    with SingleTickerProviderStateMixin {
  final List<_FloatingNumber> _floatingNumbers = [];
  late AnimationController _pulseController;
  final GlobalKey<CoinTapAnimatorState> _coinKey = GlobalKey();
  bool _isPressed = false;
  int _tapKey = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) async {
    setState(() => _isPressed = true);

    // Trigger Kinetic Pulse
    _coinKey.currentState?.triggerTap();

    // Haptic feedback
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 15, amplitude: 64);
    }
    HapticFeedback.lightImpact();

    // Process tap
    ref.read(gameProvider.notifier).tap();

    // Get tap power for floating number
    final tapPower = ref.read(tapPowerProvider);

    // Check if still mounted before using context
    if (!mounted) return;

    // Add floating number at tap position
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);

    setState(() {
      _floatingNumbers.add(
        _FloatingNumber(
          key: _tapKey++,
          amount: tapPower.round(),
          position: localPos,
        ),
      );
    });

    // Remove after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _floatingNumbers.removeWhere((n) => n.key == _tapKey - 1);
        });
      }
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final user = gameState.user;
    final pendingTaps = gameState.pendingTaps;
    final pendingCoins = gameState.pendingCoins;
    final canClaim = gameState.canClaim;
    final pendingPassive = gameState.pendingPassive;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.background,
              ],
            ),
          ),
        ),

        // Main content
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Balance card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LargeCoinDisplay(coins: user.coinBalance),
              ),

              const SizedBox(height: 16),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: HugeIcons.strokeRoundedTap02,
                        label: 'Tap Power',
                        value: '+${user.effectiveTapPower.toStringAsFixed(1)}',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: HugeIcons.strokeRoundedTime01,
                        label: 'Passive',
                        value:
                            '+${user.effectivePassiveRate.toStringAsFixed(1)}/s',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Passive earnings banner
              if (pendingPassive != null && pendingPassive.coins > 0)
                _PassiveBanner(
                  coins: pendingPassive.coins,
                  duration: pendingPassive.duration,
                  onClaim: () => widget.onClaimRequired?.call(),
                ),

              const Spacer(),

              // Tap button area
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTapDown: _handleTap,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Floating numbers
                      ..._floatingNumbers.map(
                        (fn) => Positioned(
                          left: fn.position.dx - 30,
                          top: fn.position.dy - 50,
                          child: _FloatingNumberWidget(
                            key: ValueKey(fn.key),
                            amount: fn.amount,
                          ),
                        ),
                      ),

                      // Outer glow ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 260 + (_pulseController.value * 20),
                            height: 260 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.2 + (_pulseController.value * 0.1),
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                      // Mining button (Wrapped in CoinTapAnimator)
                      CoinTapAnimator(
                        key: _coinKey,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 220, // Fixed size
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: _isPressed ? 0.8 : 0.5,
                                ),
                                blurRadius: _isPressed ? 40 : 25,
                                spreadRadius: _isPressed ? 10 : 5,
                              ),
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                HugeIcons.strokeRoundedTap02,
                                size: 72,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'TAP',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TapProgressBar(
                  currentTaps: pendingTaps,
                  maxTaps: AppConstants.tapsPerClaim,
                  canClaim: canClaim,
                ),
              ),

              // Claim button
              if (canClaim)
                Padding(
                      padding: const EdgeInsets.all(24),
                      child: GradientButton(
                        text: 'CLAIM $pendingCoins COINS',
                        icon: HugeIcons.strokeRoundedGift,
                        width: double.infinity,
                        gradientColors: AppColors.successGradient,
                        onPressed: () => widget.onClaimRequired?.call(),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    )
              else
                const SizedBox(height: 100),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloatingNumber {
  final int key;
  final int amount;
  final Offset position;

  _FloatingNumber({
    required this.key,
    required this.amount,
    required this.position,
  });
}

class _FloatingNumberWidget extends StatelessWidget {
  final int amount;

  const _FloatingNumberWidget({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Text(
          '+$amount',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.coinGold,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: AppColors.coinGold.withValues(alpha: 0.7),
                blurRadius: 12,
              ),
            ],
          ),
        )
        .animate()
        .moveY(begin: 0, end: -80, duration: 700.ms, curve: Curves.easeOutCubic)
        .fadeOut(delay: 400.ms, duration: 300.ms)
        .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3));
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
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
      ),
    );
  }
}

class _PassiveBanner extends StatelessWidget {
  final int coins;
  final Duration duration;
  final VoidCallback onClaim;

  const _PassiveBanner({
    required this.coins,
    required this.duration,
    required this.onClaim,
  });

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedMoon,
                  color: AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passive Earnings', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CoinDisplay(coins: coins, size: 16, compact: true),
                        Text(
                          ' • ${_formatDuration(duration)}',
                          style: AppTextStyles.bodySmall,
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
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    borderRadius: BorderRadius.circular(12),
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
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2000.ms,
          color: AppColors.secondary.withValues(alpha: 0.2),
        );
  }
}
