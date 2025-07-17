import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF043461);
  static const Color primaryLight = Color(0xFF1A4B73);
  static const Color primaryDark = Color(0xFF032A52);
  static const Color primaryButton = Color(0xFF5B8BB8);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF1EFEF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF93C5FD);
  static const Color accentDark = Color(0xFF1E40AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF043461), Color(0xFF1A4B73)],
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF043461), Color(0xFF096BC7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Category Colors
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categoryGreen = Color(0xFF10B981);
  static const Color categoryOrange = Color(0xFFF59E0B);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryRed = Color(0xFFEF4444);
  static const Color categoryYellow = Color(0xFFFBBF24);

  // Disabled Colors
  static const Color disabled = Color(0xFFF3F4F6);
  static const Color disabledText = Color(0xFF9CA3AF);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x4D000000);

  // App Bar Colors
  static const Color appBarBackground = primary;
  static const Color appBarText = textWhite;

  // Bottom Navigation Colors
  static const Color bottomNavBackground = primary;
  static const Color bottomNavSelected = textWhite;
  static const Color bottomNavUnselected = Color(0xB3FFFFFF);
}
