import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Gradient button with glow effect
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final double? width;
  final double height;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradientColors,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.borderRadius = 16,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? AppColors.primaryGradient;
    final isDisabled = !widget.enabled || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.95 : 1.0,
          _isPressed ? 0.95 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? [AppColors.surface, AppColors.surfaceLight]
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: colors.first.withValues(
                      alpha: _isPressed ? 0.6 : 0.4,
                    ),
                    blurRadius: _isPressed ? 16 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      isDisabled ? AppColors.textMuted : Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: isDisabled ? AppColors.textMuted : Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonText.copyWith(
                        color: isDisabled ? AppColors.textMuted : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Outlined button with neon glow
class NeonOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double? width;
  final double height;
  final IconData? icon;

  const NeonOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.width,
    this.height = 48,
    this.icon,
  });

  @override
  State<NeonOutlineButton> createState() => _NeonOutlineButtonState();
}

class _NeonOutlineButtonState extends State<NeonOutlineButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovered
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: color, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: AppTextStyles.labelLarge.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon button with glow
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 48,
    this.tooltip,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.9 : 1.0,
          _isPressed ? 0.9 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(widget.icon, color: color, size: widget.size * 0.5),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
