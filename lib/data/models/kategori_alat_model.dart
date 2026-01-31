// lib/data/models/kategori_alat_model.dart
import '../../domain/entities/kategori_alat.dart';

class KategoriAlatModel extends KategoriAlat {
  KategoriAlatModel({
    required super.id,
    required super.kode,
    required super.nama,
    required super.createdAt,
    super.updatedAt,
  });

  factory KategoriAlatModel.fromSupabase(Map<String, dynamic> json) {
    return KategoriAlatModel(
      id: json['id_kategori'] as String,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': id,
      'kode': kode,
      'nama': nama,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}