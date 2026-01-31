// lib/domain/entities/peminjaman.dart
import 'app_user.dart';
import 'peminjaman_item.dart';

class Peminjaman {
  final String id;
  final String? kodePeminjaman;
  final String peminjamId;
  final String status; // menunggu, disetujui, dibatalkan, ditolak, sebagian, selesai
  final String? disetujuiOleh;
  final DateTime? disetujuiPada;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int version;

  // Relasi
  final AppUser? peminjam;
  final AppUser? petugas;
  final List<PeminjamanItem> items;

  Peminjaman({
    required this.id,
    this.kodePeminjaman,
    required this.peminjamId,
    required this.status,
    this.disetujuiOleh,
    this.disetujuiPada,
    required this.createdAt,
    this.updatedAt,
    this.version = 1,
    this.peminjam,
    this.petugas,
    this.items = const [],
  });

  // Helper getters untuk UI
  int get totalItems => items.length;
  int get returnedItems => items.where((i) => i.status == 'dikembalikan').length;
  int get activeItems => items.where((i) => i.status == 'dipinjam').length;
  
  bool get canApprove => status == 'menunggu';
  bool get canReject => status == 'menunggu';
  bool get canCancel => status == 'menunggu';
  bool get canReturn => status == 'disetujui' || status == 'sebagian';
  bool get isSelesai => status == 'selesai';
  
  int get totalDenda => items.fold(0, (sum, item) => sum + (item.totalDenda ?? 0));
  
  String get statusDisplay {
    switch (status) {
      case 'menunggu': return 'Menunggu Persetujuan';
      case 'disetujui': return 'Disetujui';
      case 'dibatalkan': return 'Dibatalkan';
      case 'ditolak': return 'Ditolak';
      case 'sebagian': return 'Sebagian Dikembalikan';
      case 'selesai': return 'Selesai';
      default: return status;
    }
  }

  Peminjaman copyWith({
    String? id,
    String? kodePeminjaman,
    String? peminjamId,
    String? status,
    String? disetujuiOleh,
    DateTime? disetujuiPada,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    AppUser? peminjam,
    AppUser? petugas,
    List<PeminjamanItem>? items,
  }) {
    return Peminjaman(
      id: id ?? this.id,
      kodePeminjaman: kodePeminjaman ?? this.kodePeminjaman,
      peminjamId: peminjamId ?? this.peminjamId,
      status: status ?? this.status,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      disetujuiPada: disetujuiPada ?? this.disetujuiPada,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      peminjam: peminjam ?? this.peminjam,
      petugas: petugas ?? this.petugas,
      items: items ?? this.items,
    );
  }
}