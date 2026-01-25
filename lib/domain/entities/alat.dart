// lib/domain/entities/alat.dart
class Alat {
  final String id;
  final String kode;
  final String nama;
  final String subKategoriId;
  final String kondisi; // baik, rusak, hilang
  final String status; // tersedia, dipinjam, nonaktif
  final String? lokasiSimpan;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (untuk UI)
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

  Alat copyWith({
    String? id,
    String? kode,
    String? nama,
    String? subKategoriId,
    String? kondisi,
    String? status,
    String? lokasiSimpan,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? namaSubKategori,
    String? namaKategori,
  }) {
    return Alat(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      subKategoriId: subKategoriId ?? this.subKategoriId,
      kondisi: kondisi ?? this.kondisi,
      status: status ?? this.status,
      lokasiSimpan: lokasiSimpan ?? this.lokasiSimpan,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      namaSubKategori: namaSubKategori ?? this.namaSubKategori,
      namaKategori: namaKategori ?? this.namaKategori,
    );
  }
}