import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/styles/colors.dart' as app_colors;

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: app_colors.bg,
      
      colorScheme: base.colorScheme.copyWith(
        primary: app_colors.primary,
        secondary: app_colors.primaryLight,
        surface: app_colors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: app_colors.textPrimary,
      ),
      
      // App bar with transparent luxury style
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: app_colors.textPrimary,
        ),
      ),
      
      // Premium elevated button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined button with gold border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: app_colors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: app_colors.glassBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text button with gold accent
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: app_colors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Premium input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: app_colors.glassWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: app_colors.glassBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: app_colors.primary,
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          color: app_colors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: app_colors.textSecondary,
          fontSize: 14,
        ),
        prefixIconColor: app_colors.textTertiary,
        suffixIconColor: app_colors.textTertiary,
      ),
      
      // Card theme with glass effect
      cardTheme: CardThemeData(
        color: app_colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: app_colors.glassBorder,
            width: 1,
          ),
        ),
      ),
      
      // Bottom navigation with luxury styling
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: app_colors.surface,
        selectedItemColor: app_colors.primary,
        unselectedItemColor: app_colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Snackbar styling
      snackBarTheme: SnackBarThemeData(
        backgroundColor: app_colors.surface,
        contentTextStyle: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog styling
      dialogTheme: DialogThemeData(
        backgroundColor: app_colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: app_colors.textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Divider color
      dividerTheme: DividerThemeData(
        color: app_colors.glassBorder,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme with premium typography
      textTheme: base.textTheme.copyWith(
        displayLarge: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: app_colors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: app_colors.textTertiary,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: app_colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
