// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();
  
  // Font Family
  static const String fontFamily = 'Inter';
  
  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: Color(0xFF0F172A),
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
    color: Color(0xFF0F172A),
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: Color(0xFF0F172A),
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: Color(0xFF0F172A),
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Color(0xFF334155),
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Color(0xFF475569),
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Color(0xFF64748B),
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: Color(0xFF334155),
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: Color(0xFF475569),
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.0,
    color: Color(0xFF64748B),
  );
  
  // Button
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
}