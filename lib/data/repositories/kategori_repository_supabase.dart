// lib/data/repositories/kategori_repository_supabase.dart
import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/data/models/kategori_alat_model.dart';
import 'package:peminjaman_alat/domain/entities/kategori_alat.dart';
import 'package:peminjaman_alat/domain/repositories/kategori_repository.dart';

class KategoriRepositorySupabase implements KategoriRepository {
  final SupabaseService _supabase;
  final String _table = 'kategori_alat';

  KategoriRepositorySupabase(this._supabase);

  // Realtime stream
  Stream<List<Map<String, dynamic>>> get kategoriStream => 
      _supabase.client.from(_table).stream(primaryKey: ['id_kategori']);

  @override
  Future<List<KategoriAlat>> getAllKategori() async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => KategoriAlatModel.fromSupabase(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kategori: $e');
    }
  }

  @override
  Future<KategoriAlat?> getKategoriById(String id) async {
    try {
      final response = await _supabase.client
          .from(_table)
          .select()
          .eq('id_kategori', id)
          .maybeSingle();

      if (response == null) return null;
      return KategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail kategori: $e');
    }
  }

  @override
  Future<KategoriAlat> createKategori({required String kode, required String nama}) async {
    try {
      final exists = await _supabase.client
          .from(_table)
          .select('kode')
          .eq('kode', kode)
          .maybeSingle();
          
      if (exists != null) {
        throw Exception('Kode kategori sudah digunakan');
      }

      final response = await _supabase.client
          .from(_table)
          .insert({'kode': kode.toUpperCase(), 'nama': nama})
          .select()
          .single();

      return KategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal membuat kategori: $e');
    }
  }

  @override
  Future<KategoriAlat> updateKategori(String id, {String? kode, String? nama}) async {
    try {
      final updateData = <String, dynamic>{};
      if (kode != null) updateData['kode'] = kode.toUpperCase();
      if (nama != null) updateData['nama'] = nama;

      final response = await _supabase.client
          .from(_table)
          .update(updateData)
          .eq('id_kategori', id)
          .select()
          .single();

      return KategoriAlatModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Gagal update kategori: $e');
    }
  }

  @override
  Future<void> deleteKategori(String id) async {
    try {
      // Cek apakah ada subkategori
      final subKategori = await _supabase.client
          .from('sub_kategori_alat')
          .select('id_sub_kategori')
          .eq('kategori_id', id)
          .limit(1);
          
      if (subKategori.isNotEmpty) {
        throw Exception('Tidak dapat menghapus kategori yang memiliki sub kategori');
      }

      await _supabase.client.from(_table).delete().eq('id_kategori', id);
    } catch (e) {
      throw Exception('Gagal menghapus kategori: $e');
    }
  }
}