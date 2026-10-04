import 'package:flutter/material.dart';

class AppColors {
  // Primary Luxury Black & Gold Theme
  static const Color background = Color(0xFF000000);
  static const Color secondaryBackground = Color(0xFF111111);
  static const Color card = Color(0xFF111111);
  static const Color inputBackground = Color(0xFF111111);
  
  static const Color gold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFF0C94A);
  static const Color lightGold = Color(0xFFF0C94A);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldBorder = Color(0xFFD4AF37);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFD4AF37);
  static const Color hintGrey = Color(0xFF888888);
  static const Color borderColor = Color(0xFFD4AF37);
  
  static const Color error = Color(0xFFD4AF37);
  static const Color success = Color(0xFFD4AF37);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, brightGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient authButtonGradient = LinearGradient(
    colors: [gold, brightGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headingAccentGradient = LinearGradient(
    colors: [gold, brightGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
