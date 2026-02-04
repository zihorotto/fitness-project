import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Elsődleges lila színek
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryVioletDark = Color(0xFF5B21B6);
  static const Color primaryVioletLight = Color(0xFFA78BFA);
  static const Color primaryVioletLightest = Color(0xFFEDE9FE);

  static const Color violet50 = Color(0xFFFAF5FF);
  static const Color violet100 = Color(0xFFF3E8FF);
  static const Color violet200 = Color(0xFFE9D5FF);
  static const Color violet300 = Color(0xFFD8B4FE);
  static const Color violet400 = Color(0xFFA78BFA); // primaryVioletLight
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color violet600 = Color(0xFF7C3AED); // primaryViolet
  static const Color violet700 = Color(0xFF6D28D9);
  static const Color violet800 = Color(0xFF5B21B6); // primaryVioletDark
  static const Color violet900 = Color(0xFF4C1D95);

  static const List<Color> primaryGradient = [primaryViolet, primaryVioletDark];

  static const List<Color> lightGradient = [primaryVioletLight, primaryViolet];

  static const List<Color> lightest = [violet50, violet100];
}
