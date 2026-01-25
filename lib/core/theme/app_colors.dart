// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Primary - Deep Navy (Industri/Teknik)
  static const Color primary50 = Color(0xFFEEF2FF);
  static const Color primary100 = Color(0xFFE0E7FF);
  static const Color primary200 = Color(0xFFC7D2FE);
  static const Color primary300 = Color(0xFFA5B4FC);
  static const Color primary400 = Color(0xFF818CF8);
  static const Color primary500 = Color(0xFF6366F1);
  static const Color primary600 = Color(0xFF4F46E5);
  static const Color primary700 = Color(0xFF4338CA);
  static const Color primary800 = Color(0xFF3730A3);
  static const Color primary900 = Color(0xFF312E81);
  
  // Secondary - Amber/Orange (Aksen, Warning)
  static const Color secondary50 = Color(0xFFFFFBEB);
  static const Color secondary100 = Color(0xFFFEF3C7);
  static const Color secondary200 = Color(0xFFFDE68A);
  static const Color secondary300 = Color(0xFFFCD34D);
  static const Color secondary400 = Color(0xFFFBBF24);
  static const Color secondary500 = Color(0xFFF59E0B);
  static const Color secondary600 = Color(0xFFD97706);
  static const Color secondary700 = Color(0xFFB45309);
  static const Color secondary800 = Color(0xFF92400E);
  static const Color secondary900 = Color(0xFF78350F);
  
  // Neutral - Slate
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  
  // Semantic Colors - SUCCESS (Green)
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFFBBF7D0);
  static const Color success300 = Color(0xFF86EFAC);
  static const Color success400 = Color(0xFF4ADE80);
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);
  static const Color success700 = Color(0xFF15803D);
  static const Color success800 = Color(0xFF166534);
  static const Color success900 = Color(0xFF14532D);
  
  // Semantic Colors - WARNING (Amber)
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFFCD34D);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning700 = Color(0xFFB45309);
  static const Color warning800 = Color(0xFF92400E);
  static const Color warning900 = Color(0xFF78350F);
  
  // Semantic Colors - DANGER (Red)
  static const Color danger50 = Color(0xFFFEF2F2);
  static const Color danger100 = Color(0xFFFEE2E2);
  static const Color danger200 = Color(0xFFFECACA);
  static const Color danger300 = Color(0xFFFCA5A5);
  static const Color danger400 = Color(0xFFF87171);
  static const Color danger500 = Color(0xFFEF4444);
  static const Color danger600 = Color(0xFFDC2626);
  static const Color danger700 = Color(0xFFB91C1C);
  static const Color danger800 = Color(0xFF991B1B);
  static const Color danger900 = Color(0xFF7F1D1D);
  
  // Semantic Colors - INFO (Blue)
  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info200 = Color(0xFFBFDBFE);
  static const Color info300 = Color(0xFF93C5FD);
  static const Color info400 = Color(0xFF60A5FA);
  static const Color info500 = Color(0xFF3B82F6);
  static const Color info600 = Color(0xFF2563EB);
  static const Color info700 = Color(0xFF1D4ED8);
  static const Color info800 = Color(0xFF1E40AF);
  static const Color info900 = Color(0xFF1E3A8A);
  
  // Status Colors Mapping
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
      case 'dikembalikan':
      case 'selesai':
        return success500;
      case 'dipinjam':
      case 'disetujui':
        return info500;
      case 'menunggu':
        return warning500;
      case 'rusak':
      case 'hilang':
      case 'nonaktif':
      case 'ditolak':
        return danger500;
      case 'sebagian':
        return secondary500;
      default:
        return neutral500;
    }
  }
  
  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
      case 'dikembalikan':
      case 'selesai':
        return success50;
      case 'dipinjam':
      case 'disetujui':
        return info50;
      case 'menunggu':
        return warning50;
      case 'rusak':
      case 'hilang':
      case 'nonaktif':
      case 'ditolak':
        return danger50;
      case 'sebagian':
        return secondary50;
      default:
        return neutral50;
    }
  }
}