import 'package:flutter/material.dart';

class AppColors {
  // Brand & Aesthetic
  static const Color primaryNeon = Color(0xFF8B5CF6);      // Cyber Lavender
  static const Color secondaryNeon = Color(0xFF06B6D4);    // Electric Cyan
  static const Color accentNeon = Color(0xFFEC4899);       // Pink Punch
  static const Color energyAmber = Color(0xFFF59E0B);      // Sunburst Amber

  // Dark Theme Colors (Gen-Z Aesthetic)
  static const Color darkBg = Color(0xFF0B0F19);           // Midnight Cosmic
  static const Color darkSurface = Color(0xFF131B2E);      // Deep Slate
  static const Color darkSurfaceVariant = Color(0xFF1E293B);// Muted Slate
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // 8 Official Mood Colors (Specified in IPN PDF)
  // 1: Enojado 🔴
  static const Color moodAngry = Color(0xFFEF4444);
  // 2: Triste 🟣
  static const Color moodSad = Color(0xFF8B5CF6);
  // 3: Deprimido 🔵
  static const Color moodDepressed = Color(0xFF3B82F6);
  // 4: Preocupado 🟠
  static const Color moodWorried = Color(0xFFF97316);
  // 5: Neutral ⚪
  static const Color moodNeutral = Color(0xFF94A3B8);
  // 6: Bien 🟢 (Verde suave)
  static const Color moodGood = Color(0xFF10B981);
  // 7: Feliz 🟢 (Verde esmeralda)
  static const Color moodHappy = Color(0xFF059669);
  // 8: Excelente 🟡 (Amarillo brillante)
  static const Color moodExcellent = Color(0xFFF59E0B);

  static Color getMoodColor(int moodValue) {
    switch (moodValue) {
      case 1:
        return moodAngry;
      case 2:
        return moodSad;
      case 3:
        return moodDepressed;
      case 4:
        return moodWorried;
      case 5:
        return moodNeutral;
      case 6:
        return moodGood;
      case 7:
        return moodHappy;
      case 8:
        return moodExcellent;
      default:
        return moodNeutral;
    }
  }

  // Gradients for lively cards & buttons
  static const LinearGradient waveGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

