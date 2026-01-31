// lib/domain/repositories/kategori_repository.dart
import '../entities/kategori_alat.dart';

abstract class KategoriRepository {
  Future<List<KategoriAlat>> getAllKategori();
  Future<KategoriAlat?> getKategoriById(String id);
  Future<KategoriAlat> createKategori({required String kode, required String nama});
  Future<KategoriAlat> updateKategori(String id, {String? kode, String? nama});
  Future<void> deleteKategori(String id);
}

