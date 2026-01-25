// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Pinjamin';
  static const String appVersion = '1.0.0';
  
  // Spacing Grid (4px base)
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  
  // Border Radius
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  
  // Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String rolePetugas = 'petugas';
  static const String rolePeminjam = 'peminjam';
  
  // Status Peminjaman
  static const String statusMenunggu = 'menunggu';
  static const String statusDisetujui = 'disetujui';
  static const String statusSebagian = 'sebagian';
  static const String statusSelesai = 'selesai';
  static const String statusDitolak = 'ditolak';
  
  // Status Alat
  static const String statusTersedia = 'tersedia';
  static const String statusDipinjam = 'dipinjam';
  static const String statusNonaktif = 'nonaktif';
  
  // Kondisi Alat
  static const String kondisiBaik = 'baik';
  static const String kondisiRusak = 'rusak';
  static const String kondisiHilang = 'hilang';
  
  // Denda
  static const int dendaPerHari = 5000; // Rp 5.000/hari
}