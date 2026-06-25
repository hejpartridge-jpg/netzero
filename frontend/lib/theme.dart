import 'package:flutter/material.dart';

// ── Colours ──────────────────────────────────────────────
const kPrimary    = Color(0xFFB0C42B);
const kBackground = Color(0xFFF5F5EF);
const kSurface    = Color(0xFFFFFFFF);
const kText       = Color(0xFF2C2C2C);
const kTextSubtle = Color(0xFF8A8A7A);
const kBorder     = Color(0xFFE0E0D8);

// ── App Theme ─────────────────────────────────────────────
ThemeData buildTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackground,
    colorScheme: ColorScheme.light(
      primary: kPrimary,
      surface: kSurface,
    ),
    useMaterial3: true,

    // Text styles
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kText, height: 1.1),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText),
      bodyLarge: TextStyle(fontSize: 18, color: kText, height: 1.5),
      bodyMedium: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPrimary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: kText,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
    ),
  );
}

// ── Reusable widgets ──────────────────────────────────────

// Screen wrapper — centres content in a card on web
Widget screenWrapper({required Widget child}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 480),
      child: child,
    ),
  );
}

// Section card
Widget sectionCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: child,
  );
}

// Progress bar
Widget progressBar(double value) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: LinearProgressIndicator(
      value: value,
      backgroundColor: kBorder,
      color: kPrimary,
      minHeight: 6,
    ),
  );
}