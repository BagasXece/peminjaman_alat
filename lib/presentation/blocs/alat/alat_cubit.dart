// lib/presentation/blocs/alat/alat_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peminjaman_alat/domain/repositories/alat_repository.dart';
import '../../../domain/entities/alat.dart';

part 'alat_state.dart';

class AlatCubit extends Cubit<AlatState> {
  final AlatRepository _repository;
  StreamSubscription? _streamSubscription;

  AlatCubit(this._repository) : super(AlatInitial()) {
    _initRealtime();
  }

  void _initRealtime() {
    _streamSubscription = _repository.alatStream.listen(
      (alatList) {
        // Hanya emit jika sedang loaded untuk avoid interrupt loading
        if (state is AlatLoaded) {
          final current = state as AlatLoaded;
          emit(AlatLoaded(
            alatList,
            filterStatus: current.filterStatus,
            searchQuery: current.searchQuery,
          ));
        }
      },
      onError: (e) {
        emit(AlatError('Realtime error: $e'));
      },
    );
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  Future<void> loadAlat({String? status, String? search}) async {
    emit(AlatLoading());
    try {
      final alat = await _repository.getAllAlat(status: status, search: search);
      emit(AlatLoaded(alat, filterStatus: status, searchQuery: search));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  Future<void> refreshAlat() async {
    final current = state;
    if (current is AlatLoaded) {
      await loadAlat(
        status: current.filterStatus,
        search: current.searchQuery,
      );
    } else {
      await loadAlat();
    }
  }

  Future<void> addAlat({
    required String nama,
    required String subKategoriId,
    String? lokasi,
    String kondisi = 'baik',
  }) async {
    emit(AlatLoading());
    try {
      await (_repository as dynamic).createAlat(
        nama: nama,
        subKategoriId: subKategoriId,
        lokasi: lokasi,
        kondisi: kondisi,
      );
      
      emit(const AlatActionSuccess('Alat berhasil ditambahkan'));
      await loadAlat(); // Refresh
    } catch (e) {
      emit(AlatError(e.toString()));
      // Revert ke state sebelumnya
      await loadAlat();
    }
  }

  Future<void> updateKondisiAlat(
    String id,
    String kondisi, {
    String? catatan,
  }) async {
    emit(AlatLoading());
    try {
      // ✅ Gunakan method khusus update kondisi (via stored procedure)
      await _repository.updateKondisiAlat(
        alatId: id,
        kondisiBaru: kondisi,
        catatan: catatan,
      );
      
      emit(AlatActionSuccess('Kondisi alat berhasil diupdate ke "$kondisi"'));
      await loadAlat(); // Refresh untuk lihat perubahan status
    } catch (e) {
      emit(AlatError(e.toString()));
      await loadAlat(); // Revert
    }
  }

  Future<void> editAlat({
    required String id,
    String? nama,
    String? lokasi,
    String? subKategoriId,
  }) async {
    emit(AlatLoading());
    try {
      await _repository.updateAlat(
        id: id,
        nama: nama,
        lokasi: lokasi,
        subKategoriId: subKategoriId,
      );
      
      emit(const AlatActionSuccess('Alat berhasil diperbarui'));
      await loadAlat();
    } catch (e) {
      emit(AlatError(e.toString()));
      await loadAlat();
    }
  }

  Future<void> removeAlat(String id) async {
    emit(AlatLoading());
    try {
      await _repository.deleteAlat(id);
      emit(const AlatActionSuccess('Alat berhasil dihapus'));
      await loadAlat();
    } catch (e) {
      emit(AlatError(e.toString()));
      await loadAlat();
    }
  }
}