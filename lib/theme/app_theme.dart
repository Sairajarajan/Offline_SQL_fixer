import 'package:flutter/material.dart';

/// Premium + elder-friendly design system.
/// High contrast, big type (22sp+ actions), soft depth, Material 3.
class AppTheme {
  static const navy = Color(0xFF0E1B33);
  static const indigo = Color(0xFF4F46E5);
  static const teal = Color(0xFF0EA5A0);
  static const gold = Color(0xFFF59E0B);
  static const bg = Color(0xFFF6F7FB);
  static const card = Colors.white;
  static const ink = Color(0xFF101828);
  static const muted = Color(0xFF475467);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      primary: indigo,
      secondary: teal,
      surface: card,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamilyFallback: const ['Noto Sans', 'Noto Sans Tamil', 'Roboto'],
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(fontSize: 20, color: ink, height: 1.45),
        bodyMedium: TextStyle(fontSize: 18, color: ink, height: 1.5),
        bodySmall: TextStyle(fontSize: 16, color: muted),
        labelLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.all(18),
        hintStyle: TextStyle(fontSize: 18, color: Colors.grey.shade500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)), borderSide: BorderSide(color: indigo, width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 68),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static BoxDecoration heroGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF0E1B33), Color(0xFF1E1B4B), Color(0xFF312E81)],
    ),
  );

  static BoxDecoration accentGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    ),
  );

  static BoxDecoration tealGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF0EA5A0), Color(0xFF0284C7)],
    ),
  );

  static BoxDecoration goldGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
  );
}
