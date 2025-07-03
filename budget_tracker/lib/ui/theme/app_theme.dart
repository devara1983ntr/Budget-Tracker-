import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class AppTheme {
  // Color scheme
  static const Color primaryGreen = Color(AppConstants.primaryGreen);
  static const Color darkCharcoal = Color(AppConstants.darkCharcoal);
  static const Color errorRed = Color(AppConstants.errorRed);
  static const Color lightGray = Color(AppConstants.lightGray);
  static const Color mediumGray = Color(AppConstants.mediumGray);
  static const Color darkGray = Color(AppConstants.darkGray);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      error: errorRed,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: lightGray,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: darkCharcoal,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: darkCharcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: darkCharcoal),
    ),
    cardTheme: CardTheme(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        side: const BorderSide(color: primaryGreen),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: mediumGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: mediumGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: mediumGray),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightGray,
      selectedColor: primaryGreen.withOpacity(0.2),
      labelStyle: const TextStyle(color: darkCharcoal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: lightGray,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        color: darkCharcoal,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: mediumGray,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      titleTextStyle: const TextStyle(
        color: darkCharcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: darkCharcoal,
        fontSize: 16,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: darkCharcoal,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: darkCharcoal,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: darkCharcoal,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: darkCharcoal,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: darkCharcoal,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: darkCharcoal,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: darkCharcoal,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: darkCharcoal,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: darkCharcoal,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: darkCharcoal,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: darkCharcoal,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: mediumGray,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: darkCharcoal,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: darkCharcoal,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: mediumGray,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreen,
      error: errorRed,
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: darkCharcoal,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        side: const BorderSide(color: primaryGreen),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: mediumGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: mediumGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: mediumGray),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: primaryGreen,
      unselectedItemColor: mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: primaryGreen.withOpacity(0.3),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: mediumGray,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: mediumGray,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: mediumGray,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // Additional theme extensions
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);

  // Animation curves and durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // Custom colors for charts and categories
  static List<Color> get chartColors => AppConstants.chartColors
      .map((colorValue) => Color(colorValue))
      .toList();

  // Helper methods
  static Color getCategoryColor(int colorValue) {
    return Color(colorValue);
  }

  static Color getIncomeColor() => const Color(0xFF26DE81);
  static Color getExpenseColor() => const Color(0xFFFF6B6B);

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}