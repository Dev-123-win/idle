import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// "The Orbital Extraction" Splash Screen
/// Visualizes mining lasers extracting value from the Core (App Icon).
class OrbitalExtractionSplash extends StatefulWidget {
  final VoidCallback onComplete;

  const OrbitalExtractionSplash({super.key, required this.onComplete});

  @override
  State<OrbitalExtractionSplash> createState() =>
      _OrbitalExtractionSplashState();
}

class _OrbitalExtractionSplashState extends State<OrbitalExtractionSplash>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scannerController;

  // Animations
  late Animation<double> _iconRotateX;
  late Animation<double> _iconScale;
  late Animation<double> _scannerPos;
  late Animation<double> _laserIntensity;
  late Animation<double> _glowRadius;

  @override
  void initState() {
    super.initState();

    // 1. Scanner Controller (Phase 1)
    _scannerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // 2. Main Extraction Controller (Phase 2 & 3)
    _mainController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    // --- Choreography ---

    // Phase 1: Scanner sweeps down
    _scannerPos = Tween<double>(begin: -0.2, end: 1.2).animate(CurvedAnimation(
      parent: _scannerController,
      curve: Curves.easeInOut,
    ));

    // Phase 2: Icon Rotates & Scales (3D Flip In)
    _iconRotateX = Tween<double>(begin: pi / 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // Phase 3: Lasers & Extraction (Glow Effect)
    _laserIntensity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _glowRadius = Tween<double>(begin: 0.0, end: 150.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutExpo),
      ),
    );

    // Sequence
    _startSequence();
  }

  void _startSequence() async {
    // 1. Scan
    await _scannerController.forward();
    // 2. Extract
    await _mainController.forward();
    // 3. Complete
    widget.onComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Grid (Subtle)
          CustomPaint(painter: _GridPainter()),

          // Center Stage
          Center(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_mainController, _scannerController]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // A. Mining Lasers (Behind Icon)
                    if (_laserIntensity.value > 0.01)
                      CustomPaint(
                        painter: _LaserPainter(
                            intensity: _laserIntensity.value,
                            color: AppColors.primary),
                        size: const Size(400, 400),
                      ),

                    // B. The Core Glow (bloom)
                    Container(
                      width: 120 + _glowRadius.value,
                      height: 120 + _glowRadius.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.coinGold
                                .withValues(alpha: _laserIntensity.value * 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // C. The Hero Icon (3D Transform)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..rotateX(_iconRotateX.value) // Flip effect
                        ..multiply(Matrix4.diagonal3Values(_iconScale.value,
                            _iconScale.value, _iconScale.value)),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          boxShadow: AppShadows.glowShadow(AppColors.primary),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/icons/app_icon.png'),
                      ),
                    ),

                    // D. The Scanner Line (Overlay)
                    if (_scannerController.isAnimating)
                      Positioned(
                        top: MediaQuery.of(context).size.height *
                                0.4 *
                                2 *
                                _scannerPos.value -
                            100, // Approximate positioning logic
                        child: Container(
                          width: 300,
                          height: 2,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary,
                                  blurRadius: 10,
                                  spreadRadius: 2)
                            ],
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Painters

class _LaserPainter extends CustomPainter {
  final double intensity;
  final Color color;

  _LaserPainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: intensity)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = RadialGradient(colors: [Colors.white, color])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw 4 lasers converging from corners
    // TL
    canvas.drawLine(Offset(0, 0), center, paint);
    // TR
    canvas.drawLine(Offset(size.width, 0), center, paint);
    // BL
    canvas.drawLine(Offset(0, size.height), center, paint);
    // BR
    canvas.drawLine(Offset(size.width, size.height), center, paint);

    // Add extra chaotic "sparks" if intensity is high
    if (intensity > 0.8) {
      final sparkPaint = Paint()
        ..color = AppColors.coinGold.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      final rand = Random();
      for (int i = 0; i < 10; i++) {
        canvas.drawCircle(
            center +
                Offset(
                    rand.nextDouble() * 60 - 30, rand.nextDouble() * 60 - 30),
            2.0,
            sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
