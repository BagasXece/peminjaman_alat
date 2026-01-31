// lib/data/models/alat_model.dart
import '../../domain/entities/alat.dart';

class AlatModel extends Alat {
  AlatModel({
    required super.id,
    required super.kode,
    required super.nama,
    required super.subKategoriId,
    required super.kondisi,
    required super.status,
    super.lokasiSimpan,
    super.deletedAt,
    required super.createdAt,
    required super.updatedAt,
    super.namaSubKategori,
    super.namaKategori,
  });

  factory AlatModel.fromSupabase(Map<String, dynamic> json) {
    final subKategori = json['sub_kategori_alat'] as Map<String, dynamic>?;
    final kategori = subKategori?['kategori_alat'] as Map<String, dynamic>?;
    
    return AlatModel(
      id: json['id_alat'] as String,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      subKategoriId: json['sub_kategori_id'] as String,
      kondisi: json['kondisi'] as String,
      status: json['status'] as String,
      lokasiSimpan: json['lokasi'] as String?,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      namaSubKategori: subKategori?['nama'] as String?,
      namaKategori: kategori?['nama'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alat': id,
      'kode': kode,
      'nama': nama,
      'sub_kategori_id': subKategoriId,
      'kondisi': kondisi,
      'status': status,
      'lokasi': lokasiSimpan,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}