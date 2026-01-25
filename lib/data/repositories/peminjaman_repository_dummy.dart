// lib/data/repositories/peminjaman_repository_dummy.dart
import '../../domain/entities/peminjaman.dart';
import '../../domain/entities/peminjaman_item.dart';
import '../../domain/repositories/peminjaman_repository.dart';
import '../../core/constants/app_constants.dart';
import 'dummy_data.dart';

class PeminjamanRepositoryDummy implements PeminjamanRepository {
  final List<Peminjaman> _peminjamanList = List.from(DummyData.peminjamanList);

  @override
  Future<List<Peminjaman>> getAllPeminjaman({String? status, String? peminjamId}) async {
    await Future.delayed(Duration(milliseconds: 700));
    
    var result = List<Peminjaman>.from(_peminjamanList);
    
    if (status != null && status.isNotEmpty) {
      result = result.where((p) => p.status == status).toList();
    }
    
    if (peminjamId != null && peminjamId.isNotEmpty) {
      result = result.where((p) => p.peminjamId == peminjamId).toList();
    }
    
    // Sort by createdAt desc
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return result;
  }

  @override
  Future<Peminjaman?> getPeminjamanById(String id) async {
    await Future.delayed(Duration(milliseconds: 400));
    try {
      return _peminjamanList.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Peminjaman> createPeminjaman(String peminjamId, List<Map<String, dynamic>> items) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    final newPeminjaman = Peminjaman(
      id: '880e8400-e29b-41d4-a716-${DateTime.now().millisecondsSinceEpoch}',
      peminjamId: peminjamId,
      status: 'menunggu',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      peminjam: DummyData.users.firstWhere((u) => u.id == peminjamId),
      items: items.asMap().entries.map((entry) {
        final alat = DummyData.alatList.firstWhere((a) => a.id == entry.value['alatId']);
        return PeminjamanItem(
          id: '990e8400-e29b-41d4-a716-${DateTime.now().millisecondsSinceEpoch}-${entry.key}',
          peminjamanId: '880e8400-e29b-41d4-a716-${DateTime.now().millisecondsSinceEpoch}',
          alatId: entry.value['alatId'],
          jatuhTempo: entry.value['jatuhTempo'],
          status: 'dipinjam',
          createdAt: DateTime.now(),
          alat: alat,
        );
      }).toList(),
    );
    
    _peminjamanList.add(newPeminjaman);
    return newPeminjaman;
  }

  @override
  Future<Peminjaman> approvePeminjaman(String id, String petugasId) async {
    await Future.delayed(Duration(milliseconds: 600));
    
    final index = _peminjamanList.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Peminjaman tidak ditemukan');
    
    final peminjaman = _peminjamanList[index];
    if (peminjaman.status != 'menunggu') {
      throw Exception('Peminjaman sudah diproses');
    }
    
    // Update status alat menjadi dipinjam
    for (var item in peminjaman.items) {
      final alatIndex = DummyData.alatList.indexWhere((a) => a.id == item.alatId);
      if (alatIndex != -1) {
        DummyData.alatList[alatIndex] = DummyData.alatList[alatIndex].copyWith(
          status: 'dipinjam',
          updatedAt: DateTime.now(),
        );
      }
    }
    
    final updated = Peminjaman(
      id: peminjaman.id,
      peminjamId: peminjaman.peminjamId,
      status: 'disetujui',
      disetujuiOleh: petugasId,
      disetujuiPada: DateTime.now(),
      createdAt: peminjaman.createdAt,
      updatedAt: DateTime.now(),
      peminjam: peminjaman.peminjam,
      petugas: DummyData.users.firstWhere((u) => u.id == petugasId),
      items: peminjaman.items,
    );
    
    _peminjamanList[index] = updated;
    return updated;
  }

  @override
  Future<Peminjaman> rejectPeminjaman(String id, String petugasId) async {
    await Future.delayed(Duration(milliseconds: 600));
    
    final index = _peminjamanList.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Peminjaman tidak ditemukan');
    
    final peminjaman = _peminjamanList[index];
    if (peminjaman.status != 'menunggu') {
      throw Exception('Peminjaman sudah diproses');
    }
    
    final updated = Peminjaman(
      id: peminjaman.id,
      peminjamId: peminjaman.peminjamId,
      status: 'ditolak',
      disetujuiOleh: petugasId,
      disetujuiPada: DateTime.now(),
      createdAt: peminjaman.createdAt,
      updatedAt: DateTime.now(),
      peminjam: peminjaman.peminjam,
      petugas: DummyData.users.firstWhere((u) => u.id == petugasId),
      items: peminjaman.items,
    );
    
    _peminjamanList[index] = updated;
    return updated;
  }

  @override
  Future<Peminjaman> processPengembalian(
    String peminjamanId,
    List<String> itemIds, {
    String? catatan,
  }) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    final index = _peminjamanList.indexWhere((p) => p.id == peminjamanId);
    if (index == -1) throw Exception('Peminjaman tidak ditemukan');
    
    final peminjaman = _peminjamanList[index];
    final now = DateTime.now();
    
    // Update items yang dikembalikan
    final updatedItems = peminjaman.items.map((item) {
      if (itemIds.contains(item.id) && item.status == 'dipinjam') {
        final terlambatHari = now.isAfter(item.jatuhTempo) 
            ? now.difference(item.jatuhTempo).inDays 
            : 0;
        final totalDenda = terlambatHari * AppConstants.dendaPerHari;
        
        // Update status alat menjadi tersedia
        final alatIndex = DummyData.alatList.indexWhere((a) => a.id == item.alatId);
        if (alatIndex != -1) {
          DummyData.alatList[alatIndex] = DummyData.alatList[alatIndex].copyWith(
            status: 'tersedia',
            updatedAt: now,
          );
        }
        
        return PeminjamanItem(
          id: item.id,
          peminjamanId: item.peminjamanId,
          alatId: item.alatId,
          jatuhTempo: item.jatuhTempo,
          status: 'dikembalikan',
          createdAt: item.createdAt,
          alat: item.alat,
          dikembalikanPada: now,
          terlambatHari: terlambatHari,
          totalDenda: totalDenda,
        );
      }
      return item;
    }).toList();
    
    // Tentukan status peminjaman
    final returnedCount = updatedItems.where((i) => i.status == 'dikembalikan').length;
    final totalCount = updatedItems.length;
    String newStatus;
    if (returnedCount == totalCount) {
      newStatus = 'selesai';
    } else if (returnedCount > 0) {
      newStatus = 'sebagian';
    } else {
      newStatus = peminjaman.status;
    }
    
    final totalDenda = updatedItems.fold<int>(0, (sum, i) => sum + (i.totalDenda ?? 0));
    
    final updated = Peminjaman(
      id: peminjaman.id,
      peminjamId: peminjaman.peminjamId,
      status: newStatus,
      disetujuiOleh: peminjaman.disetujuiOleh,
      disetujuiPada: peminjaman.disetujuiPada,
      createdAt: peminjaman.createdAt,
      updatedAt: now,
      peminjam: peminjaman.peminjam,
      petugas: peminjaman.petugas,
      items: updatedItems,
      totalDenda: totalDenda,
    );
    
    _peminjamanList[index] = updated;
    return updated;
  }
}