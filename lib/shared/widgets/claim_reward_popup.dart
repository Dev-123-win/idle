import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../widgets/gradient_button.dart';

/// Claim reward popup with custom confetti animation
class ClaimRewardPopup extends StatefulWidget {
  final String title;
  final String subtitle;
  final int coinAmount;
  final VoidCallback onClaim;
  final VoidCallback? onWatchAd;
  final bool showAdOption;

  const ClaimRewardPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coinAmount,
    required this.onClaim,
    this.onWatchAd,
    this.showAdOption = true,
  });

  @override
  State<ClaimRewardPopup> createState() => _ClaimRewardPopupState();
}

class _ClaimRewardPopupState extends State<ClaimRewardPopup>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<_ConfettiParticle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Generate confetti particles
    _particles = List.generate(
      50,
      (index) => _ConfettiParticle(
        color: _getRandomColor(),
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        velocity: 2 + _random.nextDouble() * 3,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        size: 8 + _random.nextDouble() * 8,
      ),
    );

    _confettiController.forward();
    _confettiController.addListener(() => setState(() {}));
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.coinGold,
      AppColors.success,
      AppColors.primary,
      AppColors.secondary,
      Colors.white,
      Colors.amber,
      Colors.orange,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main dialog
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 40,
                    color: Colors.white,
                  ),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  widget.subtitle,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Coin amount
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coinGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.coinGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/Coin.png',
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.monetization_on,
                              color: AppColors.coinGold,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+${widget.coinAmount}',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.coinGold,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 24),

                // Claim button
                GradientButton(
                  text: 'CLAIM',
                  width: double.infinity,
                  gradientColors: AppColors.successGradient,
                  icon: Icons.check_circle,
                  onPressed: widget.onClaim,
                ).animate().fadeIn(delay: 500.ms),

                // Watch ad option
                if (widget.showAdOption && widget.onWatchAd != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: widget.onWatchAd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_circle_filled,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Watch Ad for 2x Reward!',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ],
            ),
          ),

          // Custom confetti overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double velocity;
  final double rotation;
  final double rotationSpeed;
  final double size;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

/// Custom painter for confetti animation
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1 - progress);

      final x = particle.x * size.width;
      final y =
          particle.y * size.height +
          (progress * particle.velocity * size.height * 0.5);
      final rotation =
          particle.rotation + (progress * particle.rotationSpeed * 10);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Show claim reward popup
void showClaimRewardPopup(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int coinAmount,
  required VoidCallback onClaim,
  VoidCallback? onWatchAd,
  bool showAdOption = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ClaimRewardPopup(
      title: title,
      subtitle: subtitle,
      coinAmount: coinAmount,
      showAdOption: showAdOption,
      onClaim: () {
        Navigator.pop(context);
        onClaim();
      },
      onWatchAd: onWatchAd != null
          ? () {
              Navigator.pop(context);
              onWatchAd();
            }
          : null,
    ),
  );
}
