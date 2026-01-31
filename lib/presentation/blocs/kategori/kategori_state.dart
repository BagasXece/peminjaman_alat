// lib/presentation/blocs/kategori/kategori_state.dart
part of 'kategori_cubit.dart';

abstract class KategoriState extends Equatable {
  const KategoriState();
  
  @override
  List<Object?> get props => [];
}

class KategoriInitial extends KategoriState {}

class KategoriLoading extends KategoriState {}

class KategoriLoaded extends KategoriState {
  final List<KategoriAlat> kategoriList;
  const KategoriLoaded(this.kategoriList);
  
  @override
  List<Object?> get props => [kategoriList];
}

class KategoriError extends KategoriState {
  final String message;
  const KategoriError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class KategoriActionSuccess extends KategoriState {
  final String message;
  const KategoriActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}