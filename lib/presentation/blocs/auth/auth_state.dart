import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peminjaman_alat/data/repositories/user_repository_supabase.dart';
import 'package:peminjaman_alat/domain/entities/app_user.dart';

// States
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<AppUser> users;
  const UsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UserCreated extends UserState {
  final AppUser user;
  const UserCreated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserState {}

class UserUpdated extends UserState {
  final AppUser user;
  const UserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepositorySupabase _repository;

  UserCubit(this._repository) : super(UserInitial());

  Future<void> loadUsers() async {
    emit(UserLoading());
    try {
      final users = await _repository.getAllUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    emit(UserLoading());
    try {
      // Validasi input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        throw Exception('Semua field wajib diisi');
      }
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }
      if (!['admin', 'petugas', 'peminjam'].contains(role)) {
        throw Exception('Role tidak valid');
      }

      final user = await _repository.createUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      emit(UserCreated(user));
      await loadUsers(); // Refresh list
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> deleteUser(String userId) async {
    emit(UserLoading());
    try {
      await _repository.deleteUser(userId);
      emit(UserDeleted());
      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateUser(
    String userId, {
    String? displayName,
    String? role,
  }) async {
    emit(UserLoading());
    try {
      final user = await _repository.updateUser(
        userId,
        displayName: displayName,
        role: role,
      );
      emit(UserUpdated(user));
      await loadUsers();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}