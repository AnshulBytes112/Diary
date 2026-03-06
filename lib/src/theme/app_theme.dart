import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.copper,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.copper,
        secondary: AppColors.cocoa,
        surface: AppColors.bg,
      ),
    );

    final textTheme = GoogleFonts.dmSerifDisplayTextTheme(base.textTheme)
        .copyWith(
          bodyLarge: GoogleFonts.inter(textStyle: base.textTheme.bodyLarge),
          bodyMedium: GoogleFonts.inter(textStyle: base.textTheme.bodyMedium),
          bodySmall: GoogleFonts.inter(textStyle: base.textTheme.bodySmall),
          labelLarge: GoogleFonts.inter(textStyle: base.textTheme.labelLarge),
          labelMedium: GoogleFonts.inter(textStyle: base.textTheme.labelMedium),
          labelSmall: GoogleFonts.inter(textStyle: base.textTheme.labelSmall),
        )
        .apply(
          displayColor: AppColors.ink,
          bodyColor: AppColors.inkMuted,
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F1E8),
        hintStyle: const TextStyle(color: Color(0x996B5548)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.copper, width: 1.4),
        ),
      ),
    );
  }
}

