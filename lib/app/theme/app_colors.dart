import 'package:flutter/material.dart';

/// Palette StudyAI — "Cognitive Luminary" (voir DESIGN.md).
/// Light: canvas lavande-gris, surfaces blanches, Electric Indigo.
/// Dark: nocturne indigo profond.
abstract final class AppColors {
  // ——— Marque ———
  static const Color primary = Color(0xFF5B5FEF); // Electric Indigo
  static const Color primaryDeep = Color(0xFF4143D5);
  static const Color secondary = Color(0xFF8B5CF6); // Vibrant Violet
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose Red

  // ——— Light ———
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3FF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9AA1AE);
  static const Color deco = Color(0xFFE5E7EB);
  static const Color chipIndigoSoft = Color(0xFFE9EAFE);
  static const Color tabInactive = Color(0xFFEEF0FB);

  // ——— Dark ———
  static const Color darkBackground = Color(0xFF0C1020);
  static const Color darkSurface = Color(0xFF161B2E);
  static const Color darkSurfaceHigh = Color(0xFF1F2540);
  static const Color darkSurfaceHighest = Color(0xFF2A3152);
  static const Color darkPrimary = Color(0xFF9CA0FF);
  static const Color darkOnPrimary = Color(0xFF0A0C4A);
  static const Color darkOnSurface = Color(0xFFF4F5FF);
  static const Color darkOnSurfaceVariant = Color(0xFFC7CAE0);
  static const Color darkOutline = Color(0xFF3A4064);
  static const Color darkOutlineVariant = Color(0xFF2A3050);

  // ——— Helpers thème courant ———
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color cardOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color altSurfaceOf(BuildContext context) =>
      isDark(context) ? darkSurfaceHigh : surfaceAlt;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkOnSurface : textPrimary;

  static Color mutedOf(BuildContext context) =>
      isDark(context) ? darkOnSurfaceVariant : textSecondary;

  static Color softOf(BuildContext context) =>
      isDark(context) ? darkOnSurfaceVariant : textMuted;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkOutlineVariant : deco;

  static Color primaryOf(BuildContext context) =>
      isDark(context) ? darkPrimary : primary;

  static Color chipOf(BuildContext context) =>
      isDark(context) ? darkSurfaceHigh : chipIndigoSoft;

  static Color subtleOf(BuildContext context) =>
      isDark(context) ? darkSurfaceHighest : tabInactive;

  static Color onPrimaryOf(BuildContext context) =>
      isDark(context) ? darkOnPrimary : Colors.white;

  /// Dégradé signature indigo → violet.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
