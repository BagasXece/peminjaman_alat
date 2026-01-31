// lib/presentation/blocs/sub_kategori/sub_kategori_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/sub_kategori_alat.dart';
import '../../../data/repositories/sub_kategori_repository_supabase.dart';

part 'sub_kategori_state.dart';

class SubKategoriCubit extends Cubit<SubKategoriState> {
  final SubKategoriRepositorySupabase _repository;

  SubKategoriCubit(this._repository) : super(SubKategoriInitial());

  Future<void> loadSubKategori() async {
    emit(SubKategoriLoading());
    try {
      final result = await _repository.getAllSubKategori();
      emit(SubKategoriLoaded(result));
    } catch (e) {
      emit(SubKategoriError(e.toString()));
    }
  }

  Future<void> loadSubKategoriByKategori(String kategoriId) async {
    emit(SubKategoriLoading());
    try {
      final result = await _repository.getSubKategoriByKategoriId(kategoriId);
      emit(SubKategoriLoaded(result));
    } catch (e) {
      emit(SubKategoriError(e.toString()));
    }
  }

  Future<void> addSubKategori({
    required String kategoriId,
    required String kode,
    required String nama,
  }) async {
    emit(SubKategoriLoading());
    try {
      await _repository.createSubKategori(
        kategoriId: kategoriId,
        kode: kode,
        nama: nama,
      );
      await loadSubKategori();
      emit(SubKategoriActionSuccess('Sub kategori berhasil ditambahkan'));
    } catch (e) {
      emit(SubKategoriError(e.toString()));
    }
  }

  Future<void> editSubKategorie(String id, {
    String? kode,
    String? nama,
    String? kategoriId,
  }) async {
    emit(SubKategoriLoading());
    try {
      await _repository.updateSubKategori(
        id,
        kode: kode,
        nama: nama,
        kategoriId: kategoriId,
      );
      await loadSubKategori();
      emit(SubKategoriActionSuccess('Sub kategori berhasil diupdate'));
    } catch (e) {
      emit(SubKategoriError(e.toString()));
    }
  }

  Future<void> removeSubKategori(String id) async {
    emit(SubKategoriLoading());
    try {
      await _repository.deleteSubKategori(id);
      await loadSubKategori();
      emit(SubKategoriActionSuccess('Sub kategori berhasil dihapus'));
    } catch (e) {
      emit(SubKategoriError(e.toString()));
    }
  }
}