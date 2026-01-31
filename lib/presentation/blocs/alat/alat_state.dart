// lib/presentation/blocs/alat/alat_state.dart
part of 'alat_cubit.dart';

abstract class AlatState extends Equatable {
  const AlatState();

  @override
  List<Object?> get props => [];
}

class AlatInitial extends AlatState {}

class AlatLoading extends AlatState {}

class AlatLoaded extends AlatState {
  final List<Alat> alat;
  final String? filterStatus;
  final String? searchQuery;
  
  const AlatLoaded(
    this.alat, {
    this.filterStatus,
    this.searchQuery,
  });
  
  @override
  List<Object?> get props => [alat, filterStatus, searchQuery];
}

class AlatError extends AlatState {
  final String message;
  const AlatError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class AlatActionSuccess extends AlatState {
  final String message;
  const AlatActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}