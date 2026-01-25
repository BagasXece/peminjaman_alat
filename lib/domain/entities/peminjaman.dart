// lib/domain/entities/peminjaman.dart
import 'peminjaman_item.dart';
import 'app_user.dart';

class Peminjaman {
  final String id;
  final String peminjamId;
  final String status; // menunggu, disetujui, sebagian, selesai, ditolak
  final String? disetujuiOleh;
  final DateTime? disetujuiPada;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi
  final AppUser? peminjam;
  final AppUser? petugas;
  final List<PeminjamanItem> items;
  final int? totalDenda;

  Peminjaman({
    required this.id,
    required this.peminjamId,
    required this.status,
    this.disetujuiOleh,
    this.disetujuiPada,
    required this.createdAt,
    required this.updatedAt,
    this.peminjam,
    this.petugas,
    this.items = const [],
    this.totalDenda,
  });

  bool get canApprove => status == 'menunggu';
  bool get canReturn => status == 'disetujui' || status == 'sebagian';
  bool get isCompleted => status == 'selesai';
  bool get isRejected => status == 'ditolak';

  int get totalItems => items.length;
  int get returnedItems => items.where((i) => i.status == 'dikembalikan').length;
  int get pendingItems => items.where((i) => i.status == 'dipinjam').length;

  String get statusDisplay {
    switch (status) {
      case 'menunggu':
        return 'Menunggu Persetujuan';
      case 'disetujui':
        return 'Disetujui';
      case 'sebagian':
        return 'Sebagian Dikembalikan';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  int calculateTotalDenda() {
    return items.fold<int>(0, (sum, item) => sum + (item.totalDenda ?? 0));
  }
}