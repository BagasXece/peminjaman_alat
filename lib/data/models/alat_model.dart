// lib/data/models/alat_model.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/alat.dart';

class AlatModel extends Equatable {
  final String id;
  final String kode;
  final String nama;
  final String subKategoriId;
  final String kondisi;
  final String status;
  final String? lokasiSimpan;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? namaSubKategori;
  final String? namaKategori;

  const AlatModel({
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

  // Factory dari Supabase dengan handling relasi yang lebih robust
  factory AlatModel.fromSupabase(Map<String, dynamic> json) {
    // Handle nested relations dengan null-safety
    Map<String, dynamic>? subKategori;
    Map<String, dynamic>? kategori;
    
    if (json['sub_kategori_alat'] is Map) {
      subKategori = json['sub_kategori_alat'] as Map<String, dynamic>;
      if (subKategori['kategori_alat'] is Map) {
        kategori = subKategori['kategori_alat'] as Map<String, dynamic>;
      }
    }

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

  // Convert ke Entity (Domain)
  Alat toEntity() => Alat(
        id: id,
        kode: kode,
        nama: nama,
        subKategoriId: subKategoriId,
        kondisi: kondisi,
        status: status,
        lokasiSimpan: lokasiSimpan,
        deletedAt: deletedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        namaSubKategori: namaSubKategori,
        namaKategori: namaKategori,
      );

  // Untuk insert/update ke Supabase (exclude computed fields)
  Map<String, dynamic> toJson() {
    return {
      'id_alat': id,
      'kode': kode,
      'nama': nama,
      'sub_kategori_id': subKategoriId,
      'kondisi': kondisi,
      'status': status,
      'lokasi': lokasiSimpan,
    };
  }

  @override
  List<Object?> get props => [
        id, kode, nama, subKategoriId, kondisi, status,
        lokasiSimpan, deletedAt, namaSubKategori, namaKategori
      ];
}