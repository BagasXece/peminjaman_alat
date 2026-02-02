// lib/data/repositories/alat_repository_supabase.dart
// Tambahkan method untuk check ketersediaan dan validasi

import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/data/models/alat_model.dart';
import 'package:peminjaman_alat/domain/entities/alat.dart';
import 'package:peminjaman_alat/domain/repositories/alat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AlatRepositorySupabase implements AlatRepository {
  final SupabaseService _supabase;
  final String _table = 'alat';

  AlatRepositorySupabase(this._supabase);

  // Stream untuk realtime updates
  // Repository - Fix realtime stream untuk include relasi:
Stream<List<Alat>> get alatStream => 
    _supabase.client
        .from(_table)
        .stream(primaryKey: ['id_alat'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          // Fetch relasi secara manual karena Supabase realtime 
          // belum support nested relations dalam stream
          final enrichedData = await Future.wait(
            data.map((item) async {
              final detail = await _supabase.client
                  .from(_table)
                  .select('''
                    *,
                    sub_kategori_alat:sub_kategori_id (
                      nama,
                      kategori_alat:kategori_id (nama)
                    )
                  ''')
                  .eq('id_alat', item['id_alat'])
                  .single();
              return detail;
            }),
          );
          return enrichedData.map((e) => AlatModel.fromSupabase(e).toEntity()).toList();
        });

  @override
  Future<List<Alat>> getAllAlat({String? status, String? search}) async {
    try {
      var query = _supabase.client
          .from(_table)
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .filter('deleted_at', 'is', null);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('nama.ilike.%$search%,kode.ilike.%$search%');
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => _mapToAlat(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mengambil data alat: ${e.toString()}');
    }
  }

  @override
  Future<Alat?> getAlatById(String id) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .eq('id_alat', id)
          .filter('deleted_at', 'is', null)
          .maybeSingle();

      if (response == null) return null;
      return _mapToAlat(response);
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mengambil detail alat: $e');
    }
  }

  @override
  Future<List<Alat>> getAlatTersedia() async {
    return getAllAlat(status: 'tersedia');
  }

  // Validasi sebelum create/update
  Future<void> _validateAlatData({
    required String nama,
    required String subKategoriId,
    String? id, // untuk update
  }) async {
    if (nama.trim().isEmpty) {
      throw Exception('Nama alat wajib diisi');
    }
    if (subKategoriId.isEmpty) {
      throw Exception('Sub kategori wajib dipilih');
    }
    
    // Cek sub kategori exists
    final subKategori = await _supabase.client
        .from('sub_kategori_alat')
        .select('id_sub_kategori')
        .eq('id_sub_kategori', subKategoriId)
        .maybeSingle();
        
    if (subKategori == null) {
      throw Exception('Sub kategori tidak ditemukan');
    }

    // Cek nama duplikat (exclude current id untuk update)
    var dupQuery = _supabase.client
        .from(_table)
        .select('id_alat')
        .eq('nama', nama.trim())
        .filter('deleted_at', 'is', null);
        
    if (id != null) {
      dupQuery = dupQuery.neq('id_alat', id);
    }
    
    final duplicate = await dupQuery.maybeSingle();
    if (duplicate != null) {
      throw Exception('Nama alat sudah digunakan');
    }
  }

  Future<Alat> createAlat({
    required String nama,
    required String subKategoriId,
    required String lokasi,
    String kondisi = 'baik',
  }) async {
    try {
      await _validateAlatData(nama: nama, subKategoriId: subKategoriId);

      final response = await _supabase.client
          .from(_table)
          .insert({
            'nama': nama.trim(),
            'sub_kategori_id': subKategoriId,
            'lokasi': lokasi.trim(),
            'kondisi': kondisi,
            'status': 'tersedia',
          })
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .single();

      return _mapToAlat(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Kode alat sudah ada (otomatis generate gagal, coba lagi)');
      }
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal menambah alat: $e');
    }
  }

  Future<Alat> updateAlat({
    required String id,
    String? nama,
    String? lokasi,
    String? kondisi,
    String? subKategoriId,
  }) async {
    try {
      // Validasi jika ada perubahan nama atau sub kategori
      if (nama != null || subKategoriId != null) {
        final currentData = await getAlatById(id);
        if (currentData == null) throw Exception('Alat tidak ditemukan');
        
        await _validateAlatData(
          nama: nama ?? currentData.nama,
          subKategoriId: subKategoriId ?? currentData.subKategoriId,
          id: id,
        );
      }

      // Cek apakah alat sedang dipinjam untuk perubahan kondisi/status
      if (kondisi != null && kondisi != 'baik') {
        final current = await getAlatById(id);
        if (current?.status == 'dipinjam') {
          throw Exception('Tidak dapat mengubah kondisi alat yang sedang dipinjam');
        }
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (nama != null) updateData['nama'] = nama.trim();
      if (lokasi != null) updateData['lokasi'] = lokasi.trim();
      if (kondisi != null) {
        updateData['kondisi'] = kondisi;
        // Update status otomatis berdasarkan kondisi
        if (kondisi != 'baik') {
          updateData['status'] = 'tidak_tersedia';
        } else {
          updateData['status'] = 'tersedia';
        }
      }
      if (subKategoriId != null) updateData['sub_kategori_id'] = subKategoriId;

      final response = await _supabase.client
          .from(_table)
          .update(updateData)
          .eq('id_alat', id)
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .single();

      return _mapToAlat(response);
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal update alat: $e');
    }
  }

  Future<void> deleteAlat(String id) async {
    try {
      // Cek apakah alat sedang dipinjam
      final peminjamanAktif = await _supabase.client
          .from('peminjaman_item')
          .select('id_peminjaman_item')
          .eq('alat_id', id)
          .eq('status', 'dipinjam')
          .maybeSingle();
          
      if (peminjamanAktif != null) {
        throw Exception('Alat sedang dipinjam, tidak dapat dihapus');
      }

      // Soft delete
      await _supabase.client
          .from(_table)
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'status': 'nonaktif',
          })
          .eq('id_alat', id);
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal menghapus alat: $e');
    }
  }

  @override
  Future<void> updateStatusAlat(String id, String status) async {
    try {
      final validStatuses = ['tersedia', 'dipinjam', 'nonaktif', 'tidak_tersedia', 'dipesan'];
      if (!validStatuses.contains(status)) {
        throw Exception('Status tidak valid');
      }

      await _supabase.client
          .from(_table)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_alat', id);
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  Alat _mapToAlat(Map<String, dynamic> json) {
    final subKategori = json['sub_kategori_alat'] as Map<String, dynamic>?;
    final kategori = subKategori?['kategori_alat'] as Map<String, dynamic>?;
    
    return Alat(
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
}