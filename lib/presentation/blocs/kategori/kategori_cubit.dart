// lib/presentation/blocs/kategori/kategori_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/kategori_alat.dart';
import '../../../data/repositories/kategori_repository_supabase.dart';

part 'kategori_state.dart';

class KategoriCubit extends Cubit<KategoriState> {
  final KategoriRepositorySupabase _repository;
  StreamSubscription? _kategoriSubscription;

  KategoriCubit(this._repository) : super(KategoriInitial()) {
    _initRealtime();
  }

  void _initRealtime() {
    _kategoriSubscription = _repository.kategoriStream.listen((_) {
      if (state is KategoriLoaded) loadKategori();
    });
  }

  @override
  Future<void> close() {
    _kategoriSubscription?.cancel();
    return super.close();
  }

  Future<void> loadKategori() async {
    emit(KategoriLoading());
    try {
      final result = await _repository.getAllKategori();
      emit(KategoriLoaded(result));
    } catch (e) {
      emit(KategoriError(e.toString()));
    }
  }

  Future<void> addKategori({required String kode, required String nama}) async {
    try {
      // Validasi
      if (kode.trim().length < 2 || kode.trim().length > 3) {
        throw Exception('Kode kategori harus 2-3 karakter');
      }
      if (nama.trim().length < 3) {
        throw Exception('Nama kategori minimal 3 karakter');
      }
      if (!RegExp(r'^[A-Z]+$').hasMatch(kode.trim().toUpperCase())) {
        throw Exception('Kode hanya boleh huruf besar');
      }

      emit(KategoriLoading());
      await _repository.createKategori(
        kode: kode.trim().toUpperCase(), 
        nama: nama.trim()
      );
      await loadKategori();
      emit(KategoriActionSuccess('Kategori berhasil ditambahkan'));
    } catch (e) {
      emit(KategoriError(e.toString()));
    }
  }

  Future<void> editKategori(String id, {String? kode, String? nama}) async {
    try {
      if (kode != null && (kode.trim().length < 2 || kode.trim().length > 3)) {
        throw Exception('Kode kategori harus 2-3 karakter');
      }
      if (nama != null && nama.trim().length < 3) {
        throw Exception('Nama kategori minimal 3 karakter');
      }

      emit(KategoriLoading());
      await _repository.updateKategori(
        id, 
        kode: kode?.trim().toUpperCase(), 
        nama: nama?.trim()
      );
      await loadKategori();
      emit(KategoriActionSuccess('Kategori berhasil diupdate'));
    } catch (e) {
      emit(KategoriError(e.toString()));
    }
  }

  Future<void> removeKategori(String id) async {
    try {
      emit(KategoriLoading());
      await _repository.deleteKategori(id);
      await loadKategori();
      emit(KategoriActionSuccess('Kategori berhasil dihapus'));
    } catch (e) {
      emit(KategoriError(e.toString()));
    }
  }
}