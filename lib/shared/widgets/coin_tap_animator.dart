import 'package:flutter/material.dart';

/// A highly satisfying, premium tap animation widget for kinetic feedback.
/// Wraps a child (e.g., Coin) and provides a [triggerTap] method to play
/// a squash-and-rebound animation.
class CoinTapAnimator extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CoinTapAnimator({super.key, required this.child, this.onTap});

  @override
  CoinTapAnimatorState createState() => CoinTapAnimatorState();
}

class CoinTapAnimatorState extends State<CoinTapAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Duration: 150ms for rapid, snappy feedback
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // The Animation (The Math): Scale 1.0 -> 0.95
    // Curve (The Energy): easeOutBack for overshoot and rebound
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the kinetic pulse (Squash -> Rebound)
  void triggerTap() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        triggerTap();
        widget.onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
