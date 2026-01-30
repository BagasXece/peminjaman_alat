import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:peminjaman_alat/domain/entities/app_user.dart';
import 'package:peminjaman_alat/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// States
abstract class AuthCState extends Equatable {
  const AuthCState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthCState {}

class AuthLoading extends AuthCState {}

class Authenticated extends AuthCState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthCState {}

class AuthError extends AuthCState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthCState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    checkAuth();
    // Listen to auth state changes untuk session expiry
    _authSubscription = (_authRepository as dynamic).authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut) {
        emit(Unauthenticated());
      } else if (authState.event == AuthChangeEvent.tokenRefreshed) {
        // Session di-refresh, bisa reload user data jika perlu
        checkAuth();
      }
    });
  }

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Check privilege
  bool get isAdmin => state is Authenticated && (state as Authenticated).user.role == 'admin';
  bool get isPetugas => state is Authenticated && (state as Authenticated).user.role == 'petugas';
  bool get isPeminjam => state is Authenticated && (state as Authenticated).user.role == 'peminjam';

  AppUser? get currentUser => state is Authenticated ? (state as Authenticated).user : null;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}