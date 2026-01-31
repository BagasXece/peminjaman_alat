// lib/presentation/blocs/sub_kategori/sub_kategori_state.dart
part of 'sub_kategori_cubit.dart';

abstract class SubKategoriState extends Equatable {
  const SubKategoriState();
  
  @override
  List<Object?> get props => [];
}

class SubKategoriInitial extends SubKategoriState {}

class SubKategoriLoading extends SubKategoriState {}

class SubKategoriLoaded extends SubKategoriState {
  final List<SubKategoriAlat> subKategoriList;
  const SubKategoriLoaded(this.subKategoriList);
  
  @override
  List<Object?> get props => [subKategoriList];
}

class SubKategoriError extends SubKategoriState {
  final String message;
  const SubKategoriError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class SubKategoriActionSuccess extends SubKategoriState {
  final String message;
  const SubKategoriActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}