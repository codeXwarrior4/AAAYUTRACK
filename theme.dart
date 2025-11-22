// lib/theme.dart
import 'package:flutter/material.dart';

const kTeal = Color(0xFF009688);
const kMint = Color(0xFF80CBC4);
const kBgLight = Color(0xFFF7F9F9);
const kBgDark = Color(0xFF0F1115);
const kCardLight = Colors.white;
const kCardDark = Color(0xFF1E1E1E);
const kShadow = Color(0x1A000000);

/// 🌞 LIGHT THEME
ThemeData buildAayuTrackLightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: kBgLight,
    primaryColor: kTeal,
    colorScheme: base.colorScheme.copyWith(
      primary: kTeal,
      secondary: kMint,
      surface: kCardLight,
      brightness: Brightness.light,
    ),

    /// 🔧 FIX: CardThemeData instead of CardTheme
    cardTheme: const CardThemeData(
      color: kCardLight,
      elevation: 3,
      shadowColor: kShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: kTeal,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: const TextStyle(color: Colors.black87, fontSize: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: kMint.withOpacity(0.3),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.black87),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: Colors.black87),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kTeal,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}

/// 🌙 DARK THEME
ThemeData buildAayuTrackDarkTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: kBgDark,
    primaryColor: kMint,
    colorScheme: base.colorScheme.copyWith(
      primary: kMint,
      secondary: kTeal,
      surface: kCardDark,
      brightness: Brightness.dark,
    ),

    /// 🔧 FIX: CardThemeData instead of CardTheme
    cardTheme: const CardThemeData(
      color: kCardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: kMint,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),

    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      bodyMedium: const TextStyle(color: Colors.white70, fontSize: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kMint,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1A1A),
      indicatorColor: kMint.withOpacity(0.25),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white70),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: Colors.white70),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kMint,
      contentTextStyle: TextStyle(color: Colors.black87),
    ),
  );
}
