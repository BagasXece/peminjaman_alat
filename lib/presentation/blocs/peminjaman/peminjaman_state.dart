// lib/presentation/blocs/peminjaman_state.dart
part of 'peminjaman_cubit.dart';

abstract class PeminjamanState extends Equatable {
  const PeminjamanState();

  @override
  List<Object?> get props => [];
}

class PeminjamanInitial extends PeminjamanState {}

class PeminjamanLoading extends PeminjamanState {}

class PeminjamanLoaded extends PeminjamanState {
  final List<Peminjaman> peminjaman;

  const PeminjamanLoaded(this.peminjaman);

  @override
  List<Object?> get props => [peminjaman];
}

class PeminjamanDetailLoaded extends PeminjamanState {
  final Peminjaman peminjaman;

  const PeminjamanDetailLoaded(this.peminjaman);

  @override
  List<Object?> get props => [peminjaman];
}

class PeminjamanCreated extends PeminjamanState {
  final Peminjaman peminjaman;

  const PeminjamanCreated(this.peminjaman);

  @override
  List<Object?> get props => [peminjaman];
}

class PeminjamanUpdated extends PeminjamanState {
  final Peminjaman peminjaman;

  const PeminjamanUpdated(this.peminjaman);

  @override
  List<Object?> get props => [peminjaman];
}

class PeminjamanError extends PeminjamanState {
  final String message;

  const PeminjamanError(this.message);

  @override
  List<Object?> get props => [message];
}