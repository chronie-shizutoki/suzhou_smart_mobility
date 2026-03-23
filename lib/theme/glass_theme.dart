import 'package:flutter/material.dart';

class GlassTheme {
  static ThemeData get lightTheme {
    return _buildLightTheme(careMode: false);
  }

  static ThemeData get lightThemeCareMode {
    return _buildLightTheme(careMode: true);
  }

  static ThemeData _buildLightTheme({required bool careMode}) {
    final fontSizeMultiplier = careMode ? 1.4 : 1.0;
    final textTheme = _buildTextTheme(Brightness.light, fontSizeMultiplier);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _buildLightColorScheme(careMode),
      scaffoldBackgroundColor: careMode ? const Color(0xFFF5F5F5) : const Color(0xFFF0F4F8),
      cardTheme: CardThemeData(
        elevation: careMode ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: careMode ? const BorderSide(color: Color(0xFF003366), width: 2) : BorderSide.none,
        ),
        color: careMode ? const Color(0xFFFFFFFF) : const Color(0xB3FFFFFF),
      ),
      appBarTheme: AppBarTheme(
        elevation: careMode ? 4 : 0,
        backgroundColor: careMode ? const Color(0xFFFFFFFF) : Colors.transparent,
        foregroundColor: careMode ? const Color(0xFF000000) : const Color(0xFF1A1A2E),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: careMode ? const Color(0xFFFFFFFF) : Colors.white.withValues(alpha: 0.8),
        elevation: careMode ? 8 : 0,
        selectedItemColor: careMode ? const Color(0xFF003366) : Colors.blue,
        unselectedItemColor: careMode ? const Color(0xFF000000) : Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: careMode ? const Color(0xFF003366) : Colors.blue.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        elevation: careMode ? 12 : 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: careMode ? const Color(0xFFFFFFFF) : Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF003366), width: 3) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF003366), width: 3) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF003366), width: 4) : const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: careMode ? 12 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24 * fontSizeMultiplier, vertical: 12 * fontSizeMultiplier),
        ),
      ),
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: careMode ? const Color(0xFF003366) : Colors.grey,
        thickness: careMode ? 2 : 1,
      ),
      iconTheme: IconThemeData(
        color: careMode ? const Color(0xFF003366) : null,
        size: careMode ? 28 : 24,
      ),
    );
  }

  static ColorScheme _buildLightColorScheme(bool careMode) {
    if (careMode) {
      return const ColorScheme.light(
        primary: Color(0xFF003366),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF004488),
        onSecondary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        error: Color(0xFF990000),
        onError: Color(0xFFFFFFFF),
      );
    }
    return ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return _buildDarkTheme(careMode: false);
  }

  static ThemeData get darkThemeCareMode {
    return _buildDarkTheme(careMode: true);
  }

  static ThemeData _buildDarkTheme({required bool careMode}) {
    final fontSizeMultiplier = careMode ? 1.4 : 1.0;
    final textTheme = _buildTextTheme(Brightness.dark, fontSizeMultiplier);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _buildDarkColorScheme(careMode),
      scaffoldBackgroundColor: careMode ? const Color(0xFF000000) : const Color(0xFF0F0F1A),
      cardTheme: CardThemeData(
        elevation: careMode ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: careMode ? const BorderSide(color: Color(0xFF66B3FF), width: 2) : BorderSide.none,
        ),
        color: careMode ? const Color(0xFF1A1A1A) : const Color(0x19FFFFFF),
      ),
      appBarTheme: AppBarTheme(
        elevation: careMode ? 4 : 0,
        backgroundColor: careMode ? const Color(0xFF1A1A1A) : Colors.transparent,
        foregroundColor: careMode ? const Color(0xFFFFFFFF) : Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: careMode ? const Color(0xFF1A1A1A) : Colors.black.withValues(alpha: 0.8),
        elevation: careMode ? 8 : 0,
        selectedItemColor: careMode ? const Color(0xFF66B3FF) : Colors.blue,
        unselectedItemColor: careMode ? const Color(0xFFFFFFFF) : Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: careMode ? const Color(0xFF66B3FF) : Colors.blue.withValues(alpha: 0.9),
        foregroundColor: const Color(0xFF000000),
        elevation: careMode ? 12 : 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: careMode ? const Color(0xFF1A1A1A) : Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF66B3FF), width: 3) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF66B3FF), width: 3) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: careMode ? const BorderSide(color: Color(0xFF66B3FF), width: 4) : const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: careMode ? 12 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24 * fontSizeMultiplier, vertical: 12 * fontSizeMultiplier),
        ),
      ),
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: careMode ? const Color(0xFF66B3FF) : Colors.grey,
        thickness: careMode ? 2 : 1,
      ),
      iconTheme: IconThemeData(
        color: careMode ? const Color(0xFF66B3FF) : null,
        size: careMode ? 28 : 24,
      ),
    );
  }

  static ColorScheme _buildDarkColorScheme(bool careMode) {
    if (careMode) {
      return const ColorScheme.dark(
        primary: Color(0xFF66B3FF),
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF80C0FF),
        onSecondary: Color(0xFF000000),
        surface: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        error: Color(0xFFFF6666),
        onError: Color(0xFF000000),
      );
    }
    return ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness, double fontSizeMultiplier) {
    final baseTheme = brightness == Brightness.dark 
        ? ThemeData.dark(useMaterial3: true).textTheme 
        : ThemeData.light(useMaterial3: true).textTheme;
    
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: 57 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: 45 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: 36 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: 32 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: 28 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: 24 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: 22 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: 16 * fontSizeMultiplier,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: 14 * fontSizeMultiplier,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: 12 * fontSizeMultiplier,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: 11 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static BoxDecoration get glassDecorationDark {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
