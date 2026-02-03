// lib/domain/entities/alat.dart
class Alat {
  final String id;
  final String kode;
  final String nama;
  final String subKategoriId;
  final String kondisi; // baik, rusak, hilang
  final String status; // tersedia, dipesan, dipinjam, nonaktif, perbaikan, tidak_tersedia
  final String? lokasiSimpan;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? namaSubKategori;
  final String? namaKategori;

  Alat({
    required this.id,
    required this.kode,
    required this.nama,
    required this.subKategoriId,
    required this.kondisi,
    required this.status,
    this.lokasiSimpan,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.namaSubKategori,
    this.namaKategori,
  });
  
  bool get isAvailable => status == 'tersedia' && kondisi == 'baik' && deletedAt == null;
  bool get isDeleted => deletedAt != null;
}