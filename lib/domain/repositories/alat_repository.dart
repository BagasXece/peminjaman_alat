// lib/domain/repositories/alat_repository.dart

import 'package:peminjaman_alat/domain/entities/alat.dart';

abstract class AlatRepository {
  // Realtime
  Stream<List<Alat>> get alatStream;

  // Read
  Future<List<Alat>> getAllAlat({String? status, String? search});
  Future<Alat?> getAlatById(String id);
  Future<List<Alat>> getAlatTersedia();
  

  // Create
  Future<Alat> createAlat({
    required String nama,
    required String subKategoriId,
    String? lokasi,
    String kondisi,
  });

  // Update
  Future<Alat> updateAlat({
    required String id,
    String? nama,
    String? lokasi,
    String? subKategoriId,
    String? status,
  });

  Future<Alat> updateKondisiAlat({
    required String alatId,
    required String kondisiBaru,
    String? catatan,
  });

  Future<Alat> updateKondisiDanStatus({
    required String id,
    required String kondisi,
    String? statusOverride, // Optional: force status tertentu
  });

  Future<void> updateStatusAlat(String id, String status);

  // Delete
  Future<void> deleteAlat(String id);
}
