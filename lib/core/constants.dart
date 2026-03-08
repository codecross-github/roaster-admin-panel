import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F1729);
  static const card = Color(0xFF1E293B);
  static const cardDark = Color(0xFF333333);
  static const primary = Color(0xFFF97C29);
  static const accent = Color(0xFF8DC63F);
  static const premium = Color(0xFFFFD700);
  static const white = Color(0xFFFFFFFF);
  static const gray = Color(0xFF94A3B8);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const inputBorder = Color(0xFF374151);
  static const sidebarBg = Color(0xFF0D1321);
  static const pitcherBlue = Color(0xFF3B82F6);
  static const hitterGreen = Color(0xFF22C55E);
}

class AppConstants {
  static const String appName = 'Roster Radar Admin';
  static const String logoPath = 'assets/images/logo.png';

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 80.0;

  static const List<String> positions = [
    'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH',
    'RHP', 'LHP', 'RP', 'CP'
  ];

  static const List<String> levels = [
    'MLB', 'AAA', 'AA', 'A+', 'A', 'Rookie', 'DSL'
  ];

  static const List<String> pitchTypes = [
    'Fastball', 'Slider', 'Sweeper', 'Curveball', 'Changeup',
    'Cutter', 'Sinker', 'Splitter'
  ];

  static const List<String> throwsOptions = ['R', 'L'];
  static const List<String> batsOptions = ['R', 'L', 'S'];

  static const List<String> reportStatuses = [
    'Pending', 'In Progress', 'Completed'
  ];

  /// Validates a numeric text field value within a given range.
  static String? validateNumericRange(
    String? value, {
    required double min,
    required double max,
    required String fieldName,
    bool isRequired = true,
  }) {
    if (value == null || value.isEmpty) {
      return isRequired ? '$fieldName is required' : null;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < min || parsed > max) {
      return '$fieldName must be between ${min.toStringAsFixed(min.truncateToDouble() == min ? 0 : 1)} and ${max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 1)}';
    }
    return null;
  }
}
