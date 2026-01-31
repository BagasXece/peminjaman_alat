// lib/domain/entities/pengembalian_item.dart
class PengembalianItem {
  final String id;
  final DateTime dikembalikanPada;
  final int terlambatHari;
  final int totalDenda;
  final String? catatan;

  PengembalianItem({
    required this.id,
    required this.dikembalikanPada,
    required this.terlambatHari,
    required this.totalDenda,
    this.catatan,
  });
}