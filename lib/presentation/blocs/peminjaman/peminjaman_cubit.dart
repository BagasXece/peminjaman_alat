// lib/presentation/blocs/peminjaman/peminjaman_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/peminjaman.dart';
import '../../../domain/repositories/peminjaman_repository.dart';

part 'peminjaman_state.dart';

class PeminjamanCubit extends Cubit<PeminjamanState> {
  final PeminjamanRepository _peminjamanRepository;

  PeminjamanCubit(this._peminjamanRepository) : super(PeminjamanInitial());

  Future<void> loadPeminjaman({String? status, String? peminjamId}) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.getAllPeminjaman(
        status: status,
        peminjamId: peminjamId,
      );
      emit(PeminjamanLoaded(peminjaman));
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  // UPDATE: Tambahkan parameter items
  Future<void> createPeminjaman(
    String peminjamId, 
    List<Map<String, dynamic>> items,
  ) async {
    emit(PeminjamanLoading());
    try {
      // 1. Buat peminjaman kosong dulu
      final peminjaman = await _peminjamanRepository.createPeminjaman(peminjamId);
      
      // 2. Tambahkan setiap item satu per satu
      for (final item in items) {
        await _peminjamanRepository.addItemToPeminjaman(
          peminjaman.id,
          item['alatId'] as String,
          item['jatuhTempo'] as DateTime,
        );
      }
      
      // 3. Reload untuk dapat data lengkap dengan relasi
      final finalPeminjaman = await _peminjamanRepository.getPeminjamanById(peminjaman.id);
      if (finalPeminjaman != null) {
        emit(PeminjamanCreated(finalPeminjaman));
      } else {
        emit(PeminjamanError('Gagal memuat data peminjaman'));
      }
      
      // 4. Refresh list
      await loadPeminjaman(peminjamId: peminjamId);
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  // Method untuk add item terpisah (jika diperlukan manual)
  Future<void> addItemToPeminjaman(String peminjamanId, String alatId, DateTime jatuhTempo) async {
    try {
      await _peminjamanRepository.addItemToPeminjaman(peminjamanId, alatId, jatuhTempo);
      await getPeminjamanDetail(peminjamanId);
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  Future<void> approvePeminjaman(String id, String petugasId) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.approvePeminjaman(id, petugasId);
      emit(PeminjamanUpdated(peminjaman));
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  Future<void> rejectPeminjaman(String id, String alasan) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.rejectOrcancelPeminjaman(id, alasan);
      emit(PeminjamanUpdated(peminjaman));
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  Future<void> processPengembalian(
    String peminjamanId,
    List<String> itemIds, {
    String? catatan,
  }) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.processPengembalian(
        peminjamanId: peminjamanId,
        itemIds: itemIds,
        catatan: catatan,
      );
      emit(PeminjamanUpdated(peminjaman));
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  Future<void> getPeminjamanDetail(String id) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.getPeminjamanById(id);
      if (peminjaman != null) {
        emit(PeminjamanDetailLoaded(peminjaman));
      } else {
        emit(PeminjamanError('Peminjaman tidak ditemukan'));
      }
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }
}