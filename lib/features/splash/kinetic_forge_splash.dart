import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// "The Kinetic Synapse Forge" Splash Screen
/// Visualizes raw data (Cyan) being forged into value (Gold) via the mining process.
class KineticForgeSplash extends StatefulWidget {
  final VoidCallback onComplete;

  const KineticForgeSplash({super.key, required this.onComplete});

  @override
  State<KineticForgeSplash> createState() => _KineticForgeSplashState();
}

class _KineticForgeSplashState extends State<KineticForgeSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  // Particle system configuration
  final int _particleCount = 80;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInExpo,
    );

    // Initialize particles with random start positions
    _particles = List.generate(_particleCount, (index) {
      // Random angle
      final theta = _random.nextDouble() * 2 * pi;
      // Random distance factor (1.0 = screen radius)
      final r = 1.0 + _random.nextDouble() * 0.5;
      return _Particle(theta, r, _random.nextDouble());
    });

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ForgePainter(
                progress: _controller.value,
                pulse: _pulseAnimation.value,
                particles: _particles,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _ForgePainter extends CustomPainter {
  final double progress;
  final double pulse;
  final List<_Particle> particles;

  _ForgePainter({
    required this.progress,
    required this.pulse,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Base radius is roughly half the smaller screen dimension
    final radius = min(size.width, size.height) * 0.4;

    // 1. Draw "Liquid Gold" Core
    // Grows with progress, surges at the end
    final coreRadius =
        (radius * 0.15) + (radius * 0.15 * progress) + (radius * 20 * pulse);
    final corePaint = Paint()
      ..color = AppColors.coinGold.withValues(alpha: 0.8 + (0.2 * pulse))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20); // The "Glow"

    canvas.drawCircle(center, coreRadius, corePaint);

    // 2. Draw Particles (Data Bits)
    // Concept: They move from outside (radius * 2) -> Center (0)
    // Lerp: Cyan (Start) -> Amber (End/Transmutation)

    // We accelerate them based on progress.
    // Particle position r_current = start_r * (1.0 - easeIn(progress))
    final particleProgress = Curves.easeInExpo.transform(progress);

    for (var particle in particles) {
      // Current distance from center
      // Each particle moves at slightly different speed based on its 'speedFactor'
      final currentDist =
          radius *
          2.5 *
          (particle.startR -
              (particleProgress * particle.startR * particle.speedFactor));

      // If particle has hit center (dist < coreRadius), don't draw or maybe fade out
      if (currentDist < 0) continue;

      // Calculate position
      final x = center.dx + currentDist * cos(particle.theta);
      final y = center.dy + currentDist * sin(particle.theta);

      // Color Transmutation Logic
      // Far away = Cyan. Close = Amber.
      // Normalize distance: 1.0 = edge, 0.0 = center
      final distNorm = (currentDist / (radius * 2)).clamp(0.0, 1.0);
      final color = Color.lerp(
        AppColors.coinGold, // End Color
        const Color(0xFF00FFFF), // Neon Cyan Start Color
        distNorm,
      )!;

      final paint = Paint()
        ..color = color
            .withValues(alpha: (1.0 - pulse)) // Fade out during explosion
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Draw "Tail" to simulate speed
      final tailLen =
          10.0 +
          (30.0 * particleProgress); // Tail gets longer as it gets faster
      final tailX = center.dx + (currentDist + tailLen) * cos(particle.theta);
      final tailY = center.dy + (currentDist + tailLen) * sin(particle.theta);

      canvas.drawLine(Offset(x, y), Offset(tailX, tailY), paint);
    }

    // 3. Draw Lissajous Curve (The Forge Knot)
    // A complex 3D-looking wireframe that rotates
    final knotPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.3 * (1.0 - pulse))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    bool first = true;

    // Parametric Equation for 3D knot projected to 2D
    // x = A * sin(at + delta)
    // y = B * sin(bt)
    // Rotating it over time
    final rotation = progress * 2 * pi;

    for (double t = 0; t <= 2 * pi; t += 0.05) {
      // Lissajous params
      final a = 3.0; // lobedness
      final b = 2.0;

      final lx = sin(a * t + rotation);
      final ly = sin(b * t);

      // Scale to size
      final scale = radius * 0.8;
      final px = center.dx + (lx * scale);
      final py = center.dy + (ly * scale);

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, knotPaint);
  }

  @override
  bool shouldRepaint(covariant _ForgePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

class _Particle {
  final double theta; // Angle
  final double startR; // Starting radius multiplier
  final double speedFactor; // Variance in speed

  _Particle(this.theta, this.startR, this.speedFactor);
}
