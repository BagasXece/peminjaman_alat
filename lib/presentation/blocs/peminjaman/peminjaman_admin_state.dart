// lib/presentation/blocs/peminjaman/peminjaman_admin_state.dart
part of 'peminjaman_admin_cubit.dart';

abstract class PeminjamanAdminState extends Equatable {
  const PeminjamanAdminState();
  @override
  List<Object?> get props => [];
}

class PeminjamanAdminInitial extends PeminjamanAdminState {}

class PeminjamanAdminLoading extends PeminjamanAdminState {}

class PeminjamanAdminActionLoading extends PeminjamanAdminState {}

class PeminjamanAdminListLoaded extends PeminjamanAdminState {
  final List<Peminjaman> list;
  final Map<String, int> stats;
  final String? currentFilter;
  
  const PeminjamanAdminListLoaded(
    this.list, {
    required this.stats,
    this.currentFilter,
  });
  
  @override
  List<Object?> get props => [list, stats, currentFilter];
}

class PeminjamanAdminDetailLoaded extends PeminjamanAdminState {
  final Peminjaman detail;
  const PeminjamanAdminDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class PeminjamanAdminSuccess extends PeminjamanAdminState {
  final String message;
  const PeminjamanAdminSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PeminjamanAdminError extends PeminjamanAdminState {
  final String message;
  const PeminjamanAdminError(this.message);
  @override
  List<Object?> get props => [message];
}