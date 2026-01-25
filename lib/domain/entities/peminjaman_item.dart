// lib/domain/entities/peminjaman_item.dart
import 'package:peminjaman_alat/domain/entities/alat.dart';

class PeminjamanItem {
  final String id;
  final String peminjamanId;
  final String alatId;
  final DateTime jatuhTempo;
  final String status; // dipinjam, dikembalikan
  final DateTime createdAt;

  // Relasi
  final Alat? alat;
  final DateTime? dikembalikanPada;
  final int? terlambatHari;
  final int? totalDenda;

  PeminjamanItem({
    required this.id,
    required this.peminjamanId,
    required this.alatId,
    required this.jatuhTempo,
    required this.status,
    required this.createdAt,
    this.alat,
    this.dikembalikanPada,
    this.terlambatHari,
    this.totalDenda,
  });

  bool get isTerlambat {
    if (status == 'dikembalikan') return false;
    return DateTime.now().isAfter(jatuhTempo);
  }

  int get hariTerlambat {
    if (!isTerlambat) return 0;
    return DateTime.now().difference(jatuhTempo).inDays;
  }

  int calculateDenda(int tarifPerHari) {
    return hariTerlambat * tarifPerHari;
  }
}