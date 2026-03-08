import 'package:flutter/material.dart';

/// Centralized color definitions for the Aparna Education app.
/// Use [Theme.of(context).colorScheme] for theme-aware colors.
/// Use these constants only for semantic tokens that don't change with theme.
class AppColors {
  AppColors._();

  // ─── Brand Colors ────────────────────────────────────────────────
  static const Color primary = Color(0xFF64C3BF); // Teal
  static const Color primaryLight = Color(0xFF8DD6D3);
  static const Color primaryDark = Color(0xFF4AA8A4);

  static const Color secondary = Color(0xFF0338B4); // Deep Blue
  static const Color secondaryLight = Color(0xFF3A66D4);
  static const Color secondaryDark = Color(0xFF022680);

  // ─── Accent / Status Colors ──────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ─── Light Theme Surface Colors ──────────────────────────────────
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F2F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE8ECF4);

  // ─── Dark Theme Surface Colors ───────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1123);
  static const Color darkSurface = Color(0xFF1A1D35);
  static const Color darkSurfaceVariant = Color(0xFF232847);
  static const Color darkCard = Color(0xFF1E2140);
  static const Color darkDivider = Color(0xFF2E3354);

  // ─── Text Colors ─────────────────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF1A1D35);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  static const Color darkTextPrimary = Color(0xFFF0F2F8);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // ─── Gradient Definitions ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF5BB8B4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF1A56D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [darkCard, Color(0xFF252A4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [lightCard, Color(0xFFF8F9FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
