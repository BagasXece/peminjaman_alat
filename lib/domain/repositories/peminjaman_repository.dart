// lib/domain/repositories/peminjaman_repository.dart
import '../entities/peminjaman.dart';

abstract class PeminjamanRepository {
  Future<List<Peminjaman>> getAllPeminjaman({
    String? status,
    String? search,
    DateTime? from,
    DateTime? to,
    String? peminjamId,
  });
  
  Future<Peminjaman?> getPeminjamanById(String id);
  
  Future<Peminjaman> createPeminjaman(String peminjamId);
  
  Future<Peminjaman> approvePeminjaman(String peminjamanId, String petugasId);
  
  Future<Peminjaman> rejectPeminjaman(String peminjamanId, String petugasId);
  
  Future<Peminjaman> cancelPeminjaman(String peminjamanId, String userId);
  
  Future<void> addItemToPeminjaman(String peminjamanId, String alatId, DateTime jatuhTempo);
  
  Future<void> removeItemFromPeminjaman(String itemId);
  
  Future<Peminjaman> processPengembalian({
    required String peminjamanId,
    required List<String> itemIds,
    required String petugasId,
    String? catatan,
  });
  
  Future<Peminjaman> perpanjangPeminjaman({
    required String itemId,
    required int tambahanHari,
    required String alasan,
    String? petugasId,
  });
}