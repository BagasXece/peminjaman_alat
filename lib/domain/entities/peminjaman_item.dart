// lib/domain/entities/peminjaman_item.dart
import 'alat.dart';

class PeminjamanItem {
  final String id;
  final String peminjamanId;
  final String alatId;
  final DateTime jatuhTempo;
  final String status; // dipinjam, dikembalikan, dibatalkan
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int perpanjanganKe;

  // Relasi
  final Alat? alat;
  
  // Fields dari pengembalian (jika sudah dikembalikan)
  final DateTime? dikembalikanPada;
  final int? terlambatHari;
  final int? totalDenda;
  final String? catatanPengembalian;

  PeminjamanItem({
    required this.id,
    required this.peminjamanId,
    required this.alatId,
    required this.jatuhTempo,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.perpanjanganKe = 0,
    this.alat,
    this.dikembalikanPada,
    this.terlambatHari,
    this.totalDenda,
    this.catatanPengembalian,
  });

  // Helper getters untuk UI
  bool get isDikembalikan => status == 'dikembalikan';
  bool get isDipinjam => status == 'dipinjam';
  bool get isTerlambat => jatuhTempo.isBefore(DateTime.now()) && isDipinjam;
  
  int get hariTerlambat {
    if (!isTerlambat) return 0;
    return DateTime.now().difference(jatuhTempo).inDays;
  }

  int calculateDenda(int tarifPerHari) {
    if (!isTerlambat) return 0;
    return hariTerlambat * tarifPerHari;
  }

  PeminjamanItem copyWith({
    String? id,
    String? peminjamanId,
    String? alatId,
    DateTime? jatuhTempo,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? perpanjanganKe,
    Alat? alat,
    DateTime? dikembalikanPada,
    int? terlambatHari,
    int? totalDenda,
    String? catatanPengembalian,
  }) {
    return PeminjamanItem(
      id: id ?? this.id,
      peminjamanId: peminjamanId ?? this.peminjamanId,
      alatId: alatId ?? this.alatId,
      jatuhTempo: jatuhTempo ?? this.jatuhTempo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      perpanjanganKe: perpanjanganKe ?? this.perpanjanganKe,
      alat: alat ?? this.alat,
      dikembalikanPada: dikembalikanPada ?? this.dikembalikanPada,
      terlambatHari: terlambatHari ?? this.terlambatHari,
      totalDenda: totalDenda ?? this.totalDenda,
      catatanPengembalian: catatanPengembalian ?? this.catatanPengembalian,
    );
  }
}