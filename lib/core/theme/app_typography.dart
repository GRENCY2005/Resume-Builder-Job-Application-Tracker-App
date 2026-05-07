import 'package:flutter/material.dart';

/// Centralized repository for typography styles.
class AppTypography {
  static const String _fontFamily = 'Roboto'; // Standard elegant sans-serif fallback

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.bold),
      
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
      
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
      
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.normal),
      
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }
}
