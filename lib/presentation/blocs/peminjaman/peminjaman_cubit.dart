// lib/presentation/blocs/peminjaman_cubit.dart
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

  Future<void> createPeminjaman(String peminjamId, List<Map<String, dynamic>> items) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.createPeminjaman(peminjamId, items);
      emit(PeminjamanCreated(peminjaman));
      // Reload list
      await loadPeminjaman(peminjamId: peminjamId);
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

  Future<void> rejectPeminjaman(String id, String petugasId) async {
    emit(PeminjamanLoading());
    try {
      final peminjaman = await _peminjamanRepository.rejectPeminjaman(id, petugasId);
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
        peminjamanId,
        itemIds,
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