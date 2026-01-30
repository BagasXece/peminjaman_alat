// lib/presentation/blocs/alat_state.dart
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

  const AlatLoaded(this.alat);

  @override
  List<Object?> get props => [alat];
}

class AlatError extends AlatState {
  final String message;

  const AlatError(this.message);

  @override
  List<Object?> get props => [message];
}