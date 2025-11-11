import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF0050); 
  static const Color secondaryColor = Color(0xFF00F2EA);
  static const Color backgroundDark = Color(0xFF000000); 
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color accentGray = Color(0xFF222222);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundDark,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textWhite,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textWhite,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textGray,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textGray,
      ),
    ),
    iconTheme: const IconThemeData(color: textWhite, size: 26),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textWhite),
      titleTextStyle: TextStyle(
        color: textWhite,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}


class AppConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 26.0;
  static const double iconLarge = 32.0;

  // Animation Durations
  static const Duration fastAnim = Duration(milliseconds: 150);
  static const Duration normalAnim = Duration(milliseconds: 300);
  static const Duration slowAnim = Duration(milliseconds: 600);

  // TikTok-like Bottom Bar Height
  static const double bottomNavHeight = 64.0;

  // Aspect ratios (for feed-style cards)
  static const double videoAspectRatio = 9 / 16;
}