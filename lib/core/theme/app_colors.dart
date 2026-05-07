import 'package:flutter/material.dart';

/// Centralized repository of all colors used within the application.
class AppColors {
  // --- Light Theme Colors ---
  static const Color primaryLight = Color(0xFF2563EB); // Modern Royal Blue
  static const Color secondaryLight = Color(0xFF0EA5E9); // Sky Blue
  static const Color backgroundLight = Color(0xFFF8FAFC); // Very light slate
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Deep slate
  static const Color textSecondaryLight = Color(0xFF64748B);

  // --- Dark Theme Colors ---
  static const Color primaryDark = Color(0xFF3B82F6); // Brighter Blue
  static const Color secondaryDark = Color(0xFF38BDF8); // Brighter Sky Blue
  static const Color backgroundDark = Color(0xFF0F172A); // Deep slate background
  static const Color surfaceDark = Color(0xFF1E293B); // Slate surface
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // --- Utility Colors ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // --- Gradients ---
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [primaryDark, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
