import 'package:flutter/material.dart';

class AppTheme {
  // Warna-warna kustom minimalis
  static const Color background = Color(0xFF111214); // Hitam Elegan / Deep Slate
  static const Color surface = Color(0xFF1E2022);    // Abu-abu gelap untuk Card/Kotak
  static const Color primary = Color(0xFF00E676);    // Hijau Emerald menyala
  static const Color accent = Color(0xFF64FFDA);     // Teal muda
  static const Color textPrimary = Color(0xFFFFFFFF); // Putih bersih
  static const Color textSecondary = Color(0xFF8A8D90); // Abu-abu terang

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
      
      // --- PERBAIKAN DI SINI ---
      // Mengubah CardTheme menjadi CardThemeData mengikuti standar Flutter versi terbaru
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
