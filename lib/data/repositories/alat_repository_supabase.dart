// lib/data/repositories/alat_repository_supabase.dart
// Tambahkan method untuk check ketersediaan dan validasi

import 'package:flutter/foundation.dart';
import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/data/models/alat_model.dart';
import 'package:peminjaman_alat/domain/entities/alat.dart';
import 'package:peminjaman_alat/domain/repositories/alat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatRepositorySupabase implements AlatRepository {
  final SupabaseService _supabase;
  final String _table = 'alat';

  AlatRepositorySupabase(this._supabase);

  @override
  Stream<List<Alat>> get alatStream => _supabase.client
      .from(_table)
      .stream(primaryKey: ['id_alat'])
      .order('created_at', ascending: false)
      .asyncMap((data) async {
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
        return enrichedData
            .map((e) => AlatModel.fromSupabase(e).toEntity())
            .toList();
      });

  @override
  Future<List<Alat>> getAllAlat({
    String? status,
    String? search,
    List<String>? excludedStatuses,
  }) async {
    try {
      // Base query dengan join ke sub_kategori dan kategori
      var query = _supabase.client
          .from(_table)
          .select('''
            id_alat,
            kode,
            nama,
            sub_kategori_id,
            kondisi,
            status,
            lokasi,
            created_at,
            updated_at,
            deleted_at,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .isFilter('deleted_at', null);

      // Filter by status
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (excludedStatuses != null && excludedStatuses.isNotEmpty) {
        query = query.not(
          'status',
          'in',
          '(${excludedStatuses.map((s) => "'$s'").join(',')})',
        );
      }

      // Search by nama or kode (case insensitive)
      if (search != null && search.isNotEmpty) {
        // Gunakan or() untuk multiple conditions
        query = query.or('nama.ilike.%$search%,kode.ilike.%$search%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) =>
                AlatModel.fromSupabase(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('Gagal mengambil data alat: $e');
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
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response == null) return null;
      return AlatModel.fromSupabase(response).toEntity();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<List<Alat>> getAlatTersedia() async {
    return getAllAlat(status: 'tersedia');
  }

  Future<List<Alat>> getAlatBySubKategori(String subKategoriId) async {
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
          .eq('sub_kategori_id', subKategoriId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) =>
                AlatModel.fromSupabase(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data alat: $e');
    }
  }

  Future<List<Alat>> getAlatAvailableForPeminjaman() async {
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
          .eq('status', 'tersedia')
          .eq('kondisi', 'baik')
          .isFilter('deleted_at', null)
          .order('nama');

      return (response as List<dynamic>)
          .map(
            (json) =>
                AlatModel.fromSupabase(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil alat tersedia: $e');
    }
  }

  @override
  Future<Alat> createAlat({
    required String nama,
    required String subKategoriId,
    String? lokasi,
    String kondisi = 'baik',
  }) async {
    try {
      // Validasi dasar saja - TIDAK ada cek duplicate nama lagi
      await _validateCreateData(nama: nama, subKategoriId: subKategoriId);

      // Insert - kode di-generate oleh trigger database
      final response = await _supabase.client
          .from(_table)
          .update({
            'nama': nama.trim(),
            'sub_kategori_id': subKategoriId,
            'kondisi': kondisi,
            'status': 'tersedia',
            if (lokasi != null && lokasi.isNotEmpty) 'lokasi': lokasi.trim(),
          })
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .single();

      return AlatModel.fromSupabase(response).toEntity();
    } on PostgrestException catch (e) {
      // 23505 = unique_violation (hanya untuk kode yang kemungkinan race condition)
      if (e.code == '23505') {
        throw Exception('Gagal generate kode unik. Silakan coba lagi.');
      }
      debugPrint('Error: ${e.message}');
      throw Exception('Database error: ${e.message}');
    }
  }

  Future<List<Alat>> createMultipleAlat({
    required String nama,
    required String subKategoriId,
    required int jumlah,
    String? lokasi,
    String kondisi = 'baik',
  }) async {
    try {
      if (jumlah <= 0) throw Exception('Jumlah harus lebih dari 0');
      if (jumlah > 50) throw Exception('Maksimal 50 unit sekaligus');

      // Validasi sub kategori
      await _validateSubKategoriExists(subKategoriId);

      // Prepare batch data
      final List<Map<String, dynamic>> batchData = List.generate(
        jumlah,
        (_) => {
          'nama': nama.trim(),
          'sub_kategori_id': subKategoriId,
          'kondisi': kondisi,
          'status': 'tersedia',
          if (lokasi != null && lokasi.isNotEmpty) 'lokasi': lokasi.trim(),
        },
      );

      // Insert batch
      final response = await _supabase.client
          .from(_table)
          .insert(batchData)
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''');

      return (response as List<dynamic>)
          .map(
            (json) =>
                AlatModel.fromSupabase(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception(
          'Gagal generate kode unik untuk beberapa unit. Silakan coba lagi.',
        );
      }
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<Alat> updateKondisiDanStatus({
    required String id,
    required String kondisi,
    String? statusOverride, // Optional: force status tertentu
  }) async {
    try {
      final existing = await getAlatById(id);
      if (existing == null) throw Exception('Alat tidak ditemukan');

      // Hitung status otomatis berdasarkan kondisi
      String newStatus;
      if (kondisi == 'baik') {
        // Jika kondisi baik, status tersedia (kecuali sedang dipinjam/dipesan)
        if (existing.status == 'dipinjam' || existing.status == 'dipesan') {
          newStatus = existing.status; // Tetap dipinjam/dipesan
        } else {
          newStatus = 'tersedia';
        }
      } else {
        // rusak/hilang → tidak_tersedia
        newStatus = 'tidak_tersedia';
      }

      // Override jika ada
      if (statusOverride != null) {
        newStatus = statusOverride;
      }

      final response = await _supabase.client
          .from(_table)
          .update({'kondisi': kondisi, 'status': newStatus})
          .eq('id_alat', id)
          .select('''
            *,
            sub_kategori_alat:sub_kategori_id (
              nama,
              kategori_alat:kategori_id (nama)
            )
          ''')
          .single();

      return AlatModel.fromSupabase(response).toEntity();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<Alat> updateKondisiAlat({
    required String alatId,
    required String kondisiBaru,
    String? catatan,
  }) async {
    try {
      // Panggil stored procedure - ini akan handle semua logic!
      final response = await _supabase.client.rpc(
        'flutter_update_kondisi',
        params: {
          'p_alat_id': alatId,
          'p_kondisi_baru': kondisiBaru,
          'p_catatan': catatan,
        },
      );

      // Response dari stored procedure adalah JSON dengan status & message
      // Tapi kita perlu fetch ulang data alat yang terbaru
      if (response['status'] == 'error') {
        throw Exception(response['message']);
      }

      // Fetch data terbaru setelah update
      final updatedAlat = await getAlatById(alatId);
      if (updatedAlat == null) {
        throw Exception('Alat tidak ditemukan setelah update');
      }

      return updatedAlat;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Gagal update kondisi: $e');
    }
  }

  @override
  Future<Alat> updateAlat({
    required String id,
    String? nama,
    String? lokasi,
    String? subKategoriId, // HATI-HATI: ubah ini akan ubah kode!
    String? status,
  }) async {
    try {
      final existing = await getAlatById(id);
      if (existing == null) throw Exception('Alat tidak ditemukan');

      final updateData = <String, dynamic>{};

      if (nama != null && nama.trim().isNotEmpty) {
        updateData['nama'] = nama.trim();
      }
      if (lokasi != null) {
        updateData['lokasi'] = lokasi.trim();
      }
      if (status != null) {
        updateData['status'] = status;
      }

      // ⚠️ WARNING: Update sub_kategori_id akan trigger regenerate kode!
      bool willChangeKode = false;
      if (subKategoriId != null && subKategoriId != existing.subKategoriId) {
        // Cek apakah alat sedang dipinjam
        if (existing.status == 'dipinjam' || existing.status == 'dipesan') {
          throw Exception(
            'Tidak dapat mengubah sub kategori saat alat dipinjam/dipesan. '
            'Kode alat akan berubah dan merusak tracking.',
          );
        }

        willChangeKode = true;
        updateData['sub_kategori_id'] = subKategoriId;
      }

      if (updateData.isEmpty) {
        throw Exception('Tidak ada data yang diubah');
      }

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

      final result = AlatModel.fromSupabase(response).toEntity();

      // Warning jika kode berubah
      if (willChangeKode && result.kode != existing.kode) {
        // Log atau notify bahwa kode berubah
        print(
          'WARNING: Kode alat berubah dari ${existing.kode} ke ${result.kode}',
        );
      }

      return result;
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  Future<Alat> updateSubKategoriWithStrategy({
    required String alatId,
    required String newSubKategoriId,
    required String reason,
  }) async {
    try {
      final existing = await getAlatById(alatId);
      if (existing == null) throw Exception('Alat tidak ditemukan');

      // 1. Soft delete alat lama
      await deleteAlat(alatId);

      // 2. Buat alat baru dengan sub kategori baru
      final newAlat = await createAlat(
        nama: existing.nama,
        subKategoriId: newSubKategoriId,
        lokasi: existing.lokasiSimpan,
        kondisi: existing.kondisi,
      );

      // 3. Transfer history peminjaman jika perlu (opsional, complex)
      // Ini bisa dilakukan via stored procedure atau manual migration

      return newAlat;
    } catch (e) {
      throw Exception('Gagal update sub kategori: $e');
    }
  }

  @override
  Future<void> deleteAlat(String id) async {
    try {
      await _supabase.client.rpc(
        'soft_delete_alat',
        params: {
          'p_id_alat': id,
          'p_admin_id': _supabase.client.auth.currentUser?.id,
        },
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('masih dipinjam')) {
        throw Exception('Alat sedang dipinjam, tidak dapat dihapus');
      }
      throw Exception('Gagal menghapus alat: ${e.message}');
    }
  }

  @override
  Future<void> updateStatusAlat(String id, String status) async {
    const validStatuses = [
      'tersedia',
      'dipesan',
      'dipinjam',
      'nonaktif',
      'perbaikan',
      'tidak_tersedia',
    ];
    if (!validStatuses.contains(status)) {
      throw Exception('Status tidak valid: $status');
    }

    try {
      await _supabase.client
          .from(_table)
          .update({'status': status})
          .eq('id_alat', id);
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  Future<void> hardDeleteAlat(String id) async {
    try {
      await _supabase.client.from(_table).delete().eq('id_alat', id);
    } catch (e) {
      throw Exception('Gagal hard delete: $e');
    }
  }

  Future<void> _validateCreateData({
    required String nama,
    required String subKategoriId,
  }) async {
    if (nama.trim().length < 2) {
      throw Exception('Nama alat minimal 2 karakter');
    }

    await _validateSubKategoriExists(subKategoriId);
  }

  Future<void> _validateSubKategoriExists(String subKategoriId) async {
    final subKategori = await _supabase.client
        .from('sub_kategori_alat')
        .select('id_sub_kategori')
        .eq('id_sub_kategori', subKategoriId)
        .maybeSingle();

    if (subKategori == null) {
      throw Exception('Sub kategori tidak ditemukan');
    }
  }

  Future<int> getUnitCountByNamaAndSubKategori(
    String nama,
    String subKategoriId,
  ) async {
    final data = await _supabase.client
        .from(_table)
        .select('id_alat')
        .eq('nama', nama.trim())
        .eq('sub_kategori_id', subKategoriId)
        .isFilter('deleted_at', null);

    return data.length;
  }
}
