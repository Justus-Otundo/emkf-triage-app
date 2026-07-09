import 'package:flutter/material.dart';

class TriageColors {
  TriageColors._();

  // EMKF Brand Palette
  static const Color brandRed = Color(0xFFCC0000);
  static const Color brandRedDark = Color(0xFF990000);
  static const Color brandGreen = Color(0xFF006B3F);
  static const Color brandGreenLight = Color(0xFF00A859);
  static const Color brandBlack = Color(0xFF1A1A1A);
  static const Color brandBlackLight = Color(0xFF333333);

  // Priority hazard colors (aligned with brand palette)
  static const Color criticalRed = brandRed;
  static const Color criticalRedLight = Color(0xFFFFEBEE);
  static const Color criticalOrange = Color(0xFFE65100);
  static const Color criticalOrangeLight = Color(0xFFFBE9E7);
  static const Color moderateAmber = Color(0xFFFFA000);
  static const Color moderateAmberLight = Color(0xFFFFF8E1);
  static const Color stableGreen = brandGreenLight;
  static const Color stableGreenLight = Color(0xFFE8F5E9);

  static const Color scaffoldBg = Color(0xFFF5F5F5);
  static const Color cardBg = Colors.white;

  static Color priorityColor(int priority) {
    return switch (priority) {
      1 => criticalRed,
      2 => criticalOrange,
      3 => moderateAmber,
      4 => stableGreen,
      5 => const Color(0xFF2E7D32),
      _ => Colors.grey,
    };
  }

  static Color priorityBgColor(int priority) {
    return switch (priority) {
      1 => criticalRedLight,
      2 => criticalOrangeLight,
      3 => moderateAmberLight,
      4 => stableGreenLight,
      5 => const Color(0xFFF1F8E9),
      _ => Colors.grey.shade100,
    };
  }
}
