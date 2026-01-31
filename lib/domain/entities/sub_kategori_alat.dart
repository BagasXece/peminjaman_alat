// lib/domain/entities/sub_kategori_alat.dart
class SubKategoriAlat {
  final String id;
  final String kategoriId;
  final String kode;
  final String nama;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi untuk UI
  final String? namaKategori;
  final String? kodeKategori;

  SubKategoriAlat({
    required this.id,
    required this.kategoriId,
    required this.kode,
    required this.nama,
    required this.createdAt,
    this.updatedAt,
    this.namaKategori,
    this.kodeKategori,
  });

  SubKategoriAlat copyWith({
    String? id,
    String? kategoriId,
    String? kode,
    String? nama,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? namaKategori,
    String? kodeKategori,
  }) {
    return SubKategoriAlat(
      id: id ?? this.id,
      kategoriId: kategoriId ?? this.kategoriId,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      namaKategori: namaKategori ?? this.namaKategori,
      kodeKategori: kodeKategori ?? this.kodeKategori,
    );
  }
}