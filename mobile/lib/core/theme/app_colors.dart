import 'package:flutter/material.dart';

/// LevelUp Creator — Design System Colors
class AppColors {
  AppColors._();

  // ─── Backgrounds ─────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceVariant = Color(0xFF1A1A28);
  static const Color card = Color(0xFF16161F);

  // ─── Brand Colors ─────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);       // Violet electric
  static const Color primaryLight = Color(0xFF9F67FF);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color secondary = Color(0xFF06B6D4);     // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color accent = Color(0xFFEC4899);        // Pink accent

  // ─── Semantic Colors ─────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);

  // ─── Level Colors ─────────────────────────────────────────
  static const Color level1Bronze = Color(0xFFCD7F32);
  static const Color level2Silver = Color(0xFFC0C0C0);
  static const Color level3Gold = Color(0xFFFFD700);
  static const Color level4Diamond = Color(0xFFB9F2FF);

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF8F8FF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666680);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Borders ─────────────────────────────────────────────
  static const Color border = Color(0xFF252535);
  static const Color borderFocus = Color(0xFF7C3AED);

  // ─── Gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF12121A), Color(0xFF0A0A0F)],
  );

  static const LinearGradient level1Gradient = LinearGradient(
    colors: [Color(0xFFCD7F32), Color(0xFFE8A84E)],
  );

  static const LinearGradient level2Gradient = LinearGradient(
    colors: [Color(0xFF9E9E9E), Color(0xFFE0E0E0)],
  );

  static const LinearGradient level3Gradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFF176)],
  );

  static const LinearGradient level4Gradient = LinearGradient(
    colors: [Color(0xFFB9F2FF), Color(0xFF7C3AED), Color(0xFFEC4899)],
  );

  // ─── Level Gradient by level number ──────────────────────
  static LinearGradient getLevelGradient(int level) {
    switch (level) {
      case 1:
        return level1Gradient;
      case 2:
        return level2Gradient;
      case 3:
        return level3Gradient;
      case 4:
        return level4Gradient;
      default:
        return level1Gradient;
    }
  }

  static Color getLevelColor(int level) {
    switch (level) {
      case 1:
        return level1Bronze;
      case 2:
        return level2Silver;
      case 3:
        return level3Gold;
      case 4:
        return level4Diamond;
      default:
        return level1Bronze;
    }
  }
}
