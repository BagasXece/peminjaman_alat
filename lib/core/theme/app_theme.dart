// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary600,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary900,
        secondary: AppColors.secondary600,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondary100,
        onSecondaryContainer: AppColors.secondary900,
        surface: Colors.white,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        onSurfaceVariant: AppColors.neutral700,
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral200,
        error: AppColors.danger500,
        onError: Colors.white,
        errorContainer: AppColors.danger50,
        onErrorContainer: AppColors.danger700,
        background: AppColors.neutral50,
        onBackground: AppColors.neutral900,
        surfaceTint: AppColors.primary600,
      ),
      scaffoldBackgroundColor: AppColors.neutral50,
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        headlineMedium: AppTypography.h4,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // Component Themes
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral900,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h4.copyWith(color: AppColors.neutral900),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral200),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary600,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: AppColors.neutral300),
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary600,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.danger500),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral400),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primary100,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
      ),
      
      dividerTheme: DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 32,
      ),
      
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}