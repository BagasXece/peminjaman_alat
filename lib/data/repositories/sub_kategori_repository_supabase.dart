// lib/data/repositories/sub_kategori_repository_supabase.dart
import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/data/models/sub_kategori_alat_model.dart';
import 'package:peminjaman_alat/domain/entities/sub_kategori_alat.dart';
import 'package:peminjaman_alat/domain/repositories/sub_kategori_repository.dart';

class SubKategoriRepositorySupabase implements SubKategoriRepository {
  final SupabaseService _supabase;
  final String _table = 'sub_kategori_alat';

  SubKategoriRepositorySupabase(this._supabase);

  @override
  Future<List<SubKategoriAlat>> getAllSubKategori() async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select('*, kategori_alat:kategori_id (kode, nama)')
          .order('created_at', ascending: false);

      return (response as List).map((json) => SubKategoriAlatModel.fromSupabase(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data sub kategori: $e');
    }
  }

  @override
  Future<List<SubKategoriAlat>> getSubKategoriByKategoriId(String kategoriId) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select('*, kategori_alat:kategori_id (kode, nama)')
          .eq('kategori_id', kategoriId)
          .order('nama');

      return (response as List).map((json) => SubKategoriAlatModel.fromSupabase(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data sub kategori: $e');
    }
  }

  @override
  Future<SubKategoriAlat?> getSubKategoriById(String id) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select('*, kategori_alat:kategori_id (kode, nama)')
          .eq('id_sub_kategori', id)
          .single();

      if (response == null) return null;
      return SubKategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail sub kategori: $e');
    }
  }

  @override
  Future<SubKategoriAlat> createSubKategori({
    required String kategoriId,
    required String kode,
    required String nama,
  }) async {
    try {
      final exists = await _supabase.client
          .from(_table)
          .select('kode')
          .eq('kode', kode)
          .maybeSingle();
          
      if (exists != null) {
        throw Exception('Kode sub kategori sudah digunakan');
      }

      final response = await _supabase.client
          .from(_table)
          .insert({
            'kategori_id': kategoriId,
            'kode': kode.toUpperCase(),
            'nama': nama,
          })
          .select('*, kategori_alat:kategori_id (kode, nama)')
          .single();

      return SubKategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal membuat sub kategori: $e');
    }
  }

  @override
  Future<SubKategoriAlat> updateSubKategori(String id, {
    String? kode,
    String? nama,
    String? kategoriId,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (kode != null) updateData['kode'] = kode.toUpperCase();
      if (nama != null) updateData['nama'] = nama;
      if (kategoriId != null) updateData['kategori_id'] = kategoriId;

      final response = await _supabase.client
          .from(_table)
          .update(updateData)
          .eq('id_sub_kategori', id)
          .select('*, kategori_alat:kategori_id (kode, nama)')
          .single();

      return SubKategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal update sub kategori: $e');
    }
  }

  @override
  Future<void> deleteSubKategori(String id) async {
    try {
      await _supabase.client.from(_table).delete().eq('id_sub_kategori', id);
    } catch (e) {
      throw Exception('Gagal menghapus sub kategori: $e');
    }
  }
}