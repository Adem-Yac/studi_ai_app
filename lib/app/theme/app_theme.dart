import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thèmes clair/sombre StudyAI (Plus Jakarta Sans, squircles, Material 3).
abstract final class AppTheme {
  static TextTheme _text(TextTheme base, Color body, Color display) =>
      GoogleFonts.plusJakartaSansTextTheme(base).apply(
        bodyColor: body,
        displayColor: display,
      );

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.chipIndigoSoft,
      onPrimaryContainer: AppColors.primaryDeep,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEDE4FF),
      onSecondaryContainer: Color(0xFF35107A),
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.textMuted,
      outlineVariant: AppColors.deco,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkOnSurface,
      inversePrimary: AppColors.darkPrimary,
      surfaceTint: AppColors.primary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.deco,
    );

    return base.copyWith(
      textTheme: _text(base.textTheme, AppColors.textPrimary,
          AppColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: _filledButton(AppColors.primary, Colors.white),
      switchTheme: _switch(AppColors.primary, AppColors.deco, Colors.white,
          AppColors.textMuted),
      dividerTheme: const DividerThemeData(color: AppColors.deco, thickness: 1),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: Color(0xFF2C2FB0),
      onPrimaryContainer: Color(0xFFE1E0FF),
      secondary: Color(0xFFC9B6FF),
      onSecondary: Color(0xFF35107A),
      secondaryContainer: Color(0xFF52309C),
      onSecondaryContainer: Color(0xFFEDE4FF),
      tertiary: Color(0xFF4EDEA3),
      onTertiary: Color(0xFF00382A),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFDCDEFF),
      onInverseSurface: Color(0xFF1F2540),
      inversePrimary: AppColors.primary,
      surfaceTint: AppColors.darkPrimary,
      surfaceContainerLowest: Color(0xFF080B18),
      surfaceContainerLow: Color(0xFF11162A),
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceHigh,
      surfaceContainerHighest: AppColors.darkSurfaceHighest,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkOutlineVariant,
    );

    return base.copyWith(
      textTheme: _text(base.textTheme, AppColors.darkOnSurface,
          AppColors.darkOnSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme:
          _filledButton(AppColors.darkPrimary, AppColors.darkOnPrimary),
      switchTheme: _switch(AppColors.darkPrimary, AppColors.darkOutlineVariant,
          AppColors.darkOnPrimary, AppColors.darkOnSurfaceVariant),
      dividerTheme:
          const DividerThemeData(color: AppColors.darkOutlineVariant, thickness: 1),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurfaceHigh,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceHighest,
        contentTextStyle: TextStyle(color: AppColors.darkOnSurface),
      ),
    );
  }

  static FilledButtonThemeData _filledButton(Color bg, Color fg) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  static SwitchThemeData _switch(
          Color onTrack, Color offTrack, Color onThumb, Color offThumb) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? onThumb : offThumb),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? onTrack : offTrack),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      );
}
