import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0E15);
  static const Color cardDark = Color(0xFF161824);
  static const Color cardHighlight = Color(0xFF1E2235);
  static const Color navBar = Color(0xFF1A1C29);
  
  static const Color accentAmber = Colors.amberAccent;
  static const Color accentOrange = Colors.orangeAccent;
  static const Color accentBlue = Colors.blueAccent;

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white38;
  static const Color textFaint = Colors.white24;

  static const Color borderLight = Colors.white10;
  static const Color borderActive = Colors.white30;

  static const RadialGradient ambientSunGlow = RadialGradient(
    colors: [
      Color(0x38FFC107),
      Color(0x14FF9800),
      Colors.transparent,
    ],
    radius: 0.8,
  );
}

