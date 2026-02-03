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
  final DateTime? updatedAt;  // Nullable karena bisa null saat create
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
    this.updatedAt,
    this.namaSubKategori,
    this.namaKategori,
  });

  /// Factory dari Supabase response dengan handling relasi nested
  factory AlatModel.fromSupabase(Map<String, dynamic> json) {
    // Handle nested relations dengan null-safety yang lebih robust
    String? extractNamaSubKategori;
    String? extractNamaKategori;

    // Cek berbagai kemungkinan struktur response
    final subKategoriData = json['sub_kategori_alat'];
    if (subKategoriData is Map<String, dynamic>) {
      extractNamaSubKategori = subKategoriData['nama'] as String?;
      
      final kategoriData = subKategoriData['kategori_alat'];
      if (kategoriData is Map<String, dynamic>) {
        extractNamaKategori = kategoriData['nama'] as String?;
      }
    }

    // Handle datetime parsing dengan safety
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return AlatModel(
      id: json['id_alat'] as String? ?? json['id'] as String, // Fallback untuk id
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      subKategoriId: json['sub_kategori_id'] as String,
      kondisi: json['kondisi'] as String,
      status: json['status'] as String,
      lokasiSimpan: json['lokasi'] as String?,
      deletedAt: parseDateTime(json['deleted_at']),
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updated_at']),
      namaSubKategori: extractNamaSubKategori,
      namaKategori: extractNamaKategori,
    );
  }

  /// Convert ke Entity (Domain Layer)
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

  /// Untuk INSERT ke Supabase - HANYA field yang diizinkan
  /// ❌ JANGAN kirim: id_alat, kode, created_at, updated_at, deleted_at
  /// ✅ Trigger akan handle: kode (auto-generate), timestamps
  Map<String, dynamic> toInsertJson() {
    return {
      'nama': nama.trim(),
      'sub_kategori_id': subKategoriId,
      'kondisi': kondisi,
      'status': status,
      if (lokasiSimpan != null && lokasiSimpan!.isNotEmpty)
        'lokasi': lokasiSimpan,
    };
  }

  /// Untuk UPDATE ke Supabase - field yang bisa diubah
  /// ❌ JANGAN kirim: id_alat, kode, created_at (immutable)
  Map<String, dynamic> toUpdateJson() {
    return {
      if (nama.isNotEmpty) 'nama': nama.trim(),
      if (subKategoriId.isNotEmpty) 'sub_kategori_id': subKategoriId,
      if (kondisi.isNotEmpty) 'kondisi': kondisi,
      if (status.isNotEmpty) 'status': status,
      if (lokasiSimpan != null) 'lokasi': lokasiSimpan,
      // updated_at akan di-set oleh trigger tg_alat_updated
    };
  }

  AlatModel copyWith({
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
    return AlatModel(
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

  @override
  List<Object?> get props => [
        id, kode, nama, subKategoriId, kondisi, status,
        lokasiSimpan, deletedAt, namaSubKategori, namaKategori
      ];
}