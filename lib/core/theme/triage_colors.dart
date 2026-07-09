import 'package:flutter/material.dart';

class TriageColors {
  TriageColors._();

  static const Color brandRed = Color(0xFFCC0000);
  static const Color brandRedDark = Color(0xFF990000);
  static const Color brandGreen = Color(0xFF006B3F);
  static const Color brandGreenLight = Color(0xFF00A859);
  static const Color brandBlack = Color(0xFF1A1A1A);

  static const Color neutralBg = Color(0xFFF8F9FA);
  static const Color neutralSurface = Color(0xFFFFFFFF);
  static const Color neutralBorder = Color(0xFFE5E7EB);
  static const Color neutralBorderLight = Color(0xFFF3F4F6);
  static const Color neutralTextPrimary = Color(0xFF111827);
  static const Color neutralTextSecondary = Color(0xFF6B7280);
  static const Color neutralTextTertiary = Color(0xFF9CA3AF);
  static const Color neutralDisabled = Color(0xFFD1D5DB);

  static const Color criticalRed = Color(0xFFDC2626);
  static const Color criticalRedLight = Color(0xFFFEF2F2);
  static const Color criticalOrange = Color(0xFFEA580C);
  static const Color criticalOrangeLight = Color(0xFFFFF7ED);
  static const Color moderateAmber = Color(0xFFD97706);
  static const Color moderateAmberLight = Color(0xFFFFFBEB);
  static const Color stableGreen = Color(0xFF16A34A);
  static const Color stableGreenLight = Color(0xFFF0FDF4);
  static const Color stableDarkGreen = Color(0xFF15803D);
  static const Color stableDarkGreenLight = Color(0xFFF1F8E9);

  static Color priorityColor(int priority) {
    return switch (priority) {
      1 => criticalRed,
      2 => criticalOrange,
      3 => moderateAmber,
      4 => stableGreen,
      5 => stableDarkGreen,
      _ => neutralTextTertiary,
    };
  }

  static Color priorityBgColor(int priority) {
    return switch (priority) {
      1 => criticalRedLight,
      2 => criticalOrangeLight,
      3 => moderateAmberLight,
      4 => stableGreenLight,
      5 => stableDarkGreenLight,
      _ => neutralBg,
    };
  }

  static String priorityLabel(int priority) {
    return switch (priority) {
      1 => 'Critical',
      2 => 'Emergency',
      3 => 'Urgent',
      4 => 'Semi-Urgent',
      5 => 'Non-Urgent',
      _ => '',
    };
  }

  static String priorityDescription(int priority) {
    return switch (priority) {
      1 => 'Life-threatening condition requiring immediate intervention',
      2 => 'High risk of deterioration — urgent medical attention needed',
      3 => 'Moderate condition requiring prompt but not immediate care',
      4 => 'Stable condition — can await routine assessment',
      5 => 'Minor condition — non-acute, routine handling',
      _ => '',
    };
  }
}
