// lib/presentation/blocs/alat_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alat.dart';
import '../../domain/repositories/alat_repository.dart';

part 'alat_state.dart';

class AlatCubit extends Cubit<AlatState> {
  final AlatRepository _alatRepository;

  AlatCubit(this._alatRepository) : super(AlatInitial());

  Future<void> loadAlat({String? status, String? search}) async {
    emit(AlatLoading());
    try {
      final alat = await _alatRepository.getAllAlat(status: status, search: search);
      emit(AlatLoaded(alat));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }

  Future<void> loadAlatTersedia() async {
    emit(AlatLoading());
    try {
      final alat = await _alatRepository.getAlatTersedia();
      emit(AlatLoaded(alat));
    } catch (e) {
      emit(AlatError(e.toString()));
    }
  }
}