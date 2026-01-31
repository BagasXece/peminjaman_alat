// lib/data/models/sub_kategori_alat_model.dart
import '../../domain/entities/sub_kategori_alat.dart';

class SubKategoriAlatModel extends SubKategoriAlat {
  SubKategoriAlatModel({
    required super.id,
    required super.kategoriId,
    required super.kode,
    required super.nama,
    required super.createdAt,
    super.updatedAt,
    super.namaKategori,
    super.kodeKategori,
  });

  factory SubKategoriAlatModel.fromSupabase(Map<String, dynamic> json) {
    final kategori = json['kategori_alat'] as Map<String, dynamic>?;
    
    return SubKategoriAlatModel(
      id: json['id_sub_kategori'] as String,
      kategoriId: json['kategori_id'] as String,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      namaKategori: kategori?['nama'] as String?,
      kodeKategori: kategori?['kode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sub_kategori': id,
      'kategori_id': kategoriId,
      'kode': kode,
      'nama': nama,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}