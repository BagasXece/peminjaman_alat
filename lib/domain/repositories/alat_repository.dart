// lib/domain/repositories/alat_repository.dart

import 'package:peminjaman_alat/domain/entities/alat.dart';

abstract class AlatRepository {
  Future<List<Alat>> getAllAlat({String? status, String? search});
  Future<Alat?> getAlatById(String id);
  Future<List<Alat>> getAlatTersedia();
  Future<void> updateStatusAlat(String id, String status);
}