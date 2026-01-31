// lib/domain/repositories/sub_kategori_repository.dart
import '../entities/sub_kategori_alat.dart';

abstract class SubKategoriRepository {
  Future<List<SubKategoriAlat>> getAllSubKategori();
  Future<List<SubKategoriAlat>> getSubKategoriByKategoriId(String kategoriId);
  Future<SubKategoriAlat?> getSubKategoriById(String id);
  Future<SubKategoriAlat> createSubKategori({
    required String kategoriId,
    required String kode,
    required String nama,
  });
  Future<SubKategoriAlat> updateSubKategori(String id, {
    String? kode,
    String? nama,
    String? kategoriId,
  });
  Future<void> deleteSubKategori(String id);
}