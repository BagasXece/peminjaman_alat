// lib/presentation/blocs/alat/alat_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/alat.dart';
import '../../../data/repositories/alat_repository_supabase.dart';

part 'alat_state.dart';

class AlatCubit extends Cubit<AlatState> {
  final AlatRepositorySupabase _alatRepository;
  StreamSubscription? _alatSubscription;

  AlatCubit(this._alatRepository) : super(AlatInitial()) {
    _initRealtime();
  }

  void _initRealtime() {
    // Subscribe to realtime changes
    _alatSubscription = _alatRepository.alatStream.listen((_) {
      // Auto refresh saat ada perubahan data
      if (state is AlatLoaded) {
        loadAlat();
      }
    });
  }

  @override
  Future<void> close() {
    _alatSubscription?.cancel();
    return super.close();
  }

  Future<void> loadAlat({String? status, String? search}) async {
    emit(AlatLoading());
    try {
      final alat = await _alatRepository.getAllAlat(status: status, search: search);
      emit(AlatLoaded(alat, filterStatus: status, searchQuery: search));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  Future<void> loadAlatTersedia() async {
    emit(AlatLoading());
    try {
      final alat = await _alatRepository.getAlatTersedia();
      emit(AlatLoaded(alat, filterStatus: 'tersedia'));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  // Refresh untuk pull-to-refresh
  Future<void> refreshAlat() async {
    final currentState = state;
    String? currentStatus;
    String? currentSearch;
    
    if (currentState is AlatLoaded) {
      currentStatus = currentState.filterStatus;
      currentSearch = currentState.searchQuery;
    }
    
    await loadAlat(status: currentStatus, search: currentSearch);
  }

  Future<void> addAlat({
    required String nama,
    required String subKategoriId,
    required String lokasi,
    String kondisi = 'baik',
  }) async {
    emit(AlatLoading());
    try {
      // Validasi client-side
      if (nama.trim().length < 3) {
        throw Exception('Nama alat minimal 3 karakter');
      }
      
      await _alatRepository.createAlat(
        nama: nama,
        subKategoriId: subKategoriId,
        lokasi: lokasi,
        kondisi: kondisi,
      );
      
      emit(AlatActionSuccess('Alat berhasil ditambahkan'));
      await loadAlat(); // Refresh list
    } catch (e) {
      emit(AlatError(e.toString()));
      // Revert ke state sebelumnya jika ada
      if (state is AlatLoaded) {
        final prevState = state as AlatLoaded;
        emit(prevState);
      }
    }
  }

  Future<void> editAlat({
    required String id,
    String? nama,
    String? lokasi,
    String? kondisi,
    String? subKategoriId,
  }) async {
    emit(AlatLoading());
    try {
      if (nama != null && nama.trim().length < 3) {
        throw Exception('Nama alat minimal 3 karakter');
      }

      await _alatRepository.updateAlat(
        id: id,
        nama: nama,
        lokasi: lokasi,
        kondisi: kondisi,
        subKategoriId: subKategoriId,
      );
      
      emit(AlatActionSuccess('Alat berhasil diupdate'));
      await loadAlat();
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  Future<void> removeAlat(String id) async {
    emit(AlatLoading());
    try {
      await _alatRepository.deleteAlat(id);
      emit(AlatActionSuccess('Alat berhasil dihapus'));
      await loadAlat();
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  Future<void> updateKondisiAlat(String id, String kondisi, {String? catatan}) async {
    try {
      if (kondisi == 'rusak' || kondisi == 'hilang') {
        // Konfirmasi tambahan untuk kondisi kritis
        await _alatRepository.updateAlat(id: id, kondisi: kondisi);
      } else {
        await _alatRepository.updateAlat(id: id, kondisi: kondisi);
      }
      
      await loadAlat();
      emit(AlatActionSuccess('Kondisi alat berhasil diupdate'));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }
}