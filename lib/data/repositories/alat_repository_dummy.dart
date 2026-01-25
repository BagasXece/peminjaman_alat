// lib/data/repositories/alat_repository_dummy.dart
import '../../domain/entities/alat.dart';
import '../../domain/repositories/alat_repository.dart';
import 'dummy_data.dart';

class AlatRepositoryDummy implements AlatRepository {
  final List<Alat> _alatList = List.from(DummyData.alatList);

  @override
  Future<List<Alat>> getAllAlat({String? status, String? search}) async {
    await Future.delayed(Duration(milliseconds: 600));
    
    var result = _alatList.where((a) => a.deletedAt == null).toList();
    
    if (status != null && status.isNotEmpty) {
      result = result.where((a) => a.status == status).toList();
    }
    
    if (search != null && search.isNotEmpty) {
      final lowerSearch = search.toLowerCase();
      result = result.where((a) => 
        a.nama.toLowerCase().contains(lowerSearch) ||
        a.kode.toLowerCase().contains(lowerSearch) ||
        (a.namaKategori?.toLowerCase().contains(lowerSearch) ?? false)
      ).toList();
    }
    
    return result;
  }

  @override
  Future<Alat?> getAlatById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _alatList.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Alat>> getAlatTersedia() async {
    return getAllAlat(status: 'tersedia');
  }

  @override
  Future<void> updateStatusAlat(String id, String status) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = _alatList.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alatList[index] = _alatList[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }
}