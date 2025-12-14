import 'package:flutter/material.dart';

/// App color palette - Dark mode with neon crypto aesthetic
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF00D4FF); // Electric Blue
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color primaryLight = Color(0xFF66E5FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // Accent Colors
  static const Color success = Color(0xFF10B981); // Green for earnings
  static const Color error = Color(0xFFEF4444); // Red for spending
  static const Color warning = Color(0xFFF59E0B); // Amber for warnings
  static const Color info = Color(0xFF3B82F6); // Blue for info

  // Background Colors (Dark Theme)
  static const Color background = Color(0xFF0A0E17);
  static const Color backgroundSecondary = Color(0xFF111827);
  static const Color surface = Color(0xFF1F2937);
  static const Color surfaceLight = Color(0xFF374151);

  // Card Colors
  static const Color cardBackground = Color(0xFF1A1F2E);
  static const Color cardBorder = Color(0xFF2D3748);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF00D4FF),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];

  static const List<Color> neonGradient = [
    Color(0xFF00D4FF),
    Color(0xFF8B5CF6),
    Color(0xFFFF006E),
  ];

  // Coin colors
  static const Color coinGold = Color(0xFFFFD700);
  static const Color coinOrange = Color(0xFFFFA500);

  // Glow effects
  static const Color glowBlue = Color(0xFF00D4FF);
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color glowGreen = Color(0xFF10B981);
}

/// App gradients for consistent styling
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient success = LinearGradient(
    colors: AppColors.successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: AppColors.goldGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neon = LinearGradient(
    colors: AppColors.neonGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFF1A1F2E), Color(0xFF0F1419)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mining = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// App shadows for depth effects
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get neonGlow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.3),
      blurRadius: 40,
      spreadRadius: 4,
    ),
  ];
}
