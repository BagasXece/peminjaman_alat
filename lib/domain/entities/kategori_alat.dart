// lib/domain/entities/kategori_alat.dart
class KategoriAlat {
  final String id;
  final String kode;
  final String nama;
  final DateTime createdAt;
  final DateTime? updatedAt;

  KategoriAlat({
    required this.id,
    required this.kode,
    required this.nama,
    required this.createdAt,
    this.updatedAt,
  });

  KategoriAlat copyWith({
    String? id,
    String? kode,
    String? nama,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KategoriAlat(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

