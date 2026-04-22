import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryVariant,
    secondary: AppColors.primaryVariant,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    error: AppColors.error,
    onError: AppColors.onError,
    outline: AppColors.inputBorder,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge: TextStyle(color: AppColors.onBackground),
      displayMedium: TextStyle(color: AppColors.onBackground),
      displaySmall: TextStyle(color: AppColors.onBackground),
      headlineLarge: TextStyle(color: AppColors.onBackground),
      headlineMedium: TextStyle(color: AppColors.onBackground),
      headlineSmall: TextStyle(color: AppColors.onBackground),
      titleLarge: TextStyle(color: AppColors.onBackground),
      titleMedium: TextStyle(color: AppColors.onBackground),
      titleSmall: TextStyle(color: AppColors.onSurfaceVariant),
      bodyLarge: TextStyle(color: AppColors.onBackground),
      bodyMedium: TextStyle(color: AppColors.onBackground),
      bodySmall: TextStyle(color: AppColors.onSurfaceVariant),
      labelLarge: TextStyle(color: AppColors.onBackground),
      labelMedium: TextStyle(color: AppColors.onSurfaceVariant),
      labelSmall: TextStyle(color: AppColors.onSurfaceVariant),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.textHint),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.divider, space: 1),
);
