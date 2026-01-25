// lib/domain/repositories/peminjaman_repository.dart
import '../entities/peminjaman.dart';
// import '../entities/peminjaman_item.dart';

abstract class PeminjamanRepository {
  Future<List<Peminjaman>> getAllPeminjaman({String? status, String? peminjamId});
  Future<Peminjaman?> getPeminjamanById(String id);
  Future<Peminjaman> createPeminjaman(String peminjamId, List<Map<String, dynamic>> items);
  Future<Peminjaman> approvePeminjaman(String id, String petugasId);
  Future<Peminjaman> rejectPeminjaman(String id, String petugasId);
  Future<Peminjaman> processPengembalian(
    String peminjamanId,
    List<String> itemIds, {
    String? catatan,
  });
}