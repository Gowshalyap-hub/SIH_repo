import 'package:flutter/material.dart';

class AppColors {
  // Primary branding
  static const Color primary = Color(0xFF1B853F); // Green from login button
  static const Color primaryDark = Color(0xFF14602C);
  static const Color primaryLight = Color(0xFFE8F5E9);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Risk Levels / Status
  static const Color riskHigh = Color(0xFFD32F2F); // Red
  static const Color riskHighBg = Color(0xFFFFEBEE);
  
  static const Color riskModerate = Color(0xFFF57C00); // Orange
  static const Color riskModerateBg = Color(0xFFFFF3E0);
  
  static const Color riskLow = Color(0xFF81C784); // Light Green
  static const Color riskLowBg = Color(0xFFE8F5E9);
  
  static const Color riskNone = Color(0xFF388E3C); // Darker Green for No Risk
  static const Color riskNoneBg = Color(0xFFE8F5E9);

  // Borders & Dividers
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFE0E0E0);
}
