import 'package:peminjaman_alat/core/services/session_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class AuthRepositorySupabase implements AuthRepository {
  final SupabaseService _supabase;

  AuthRepositorySupabase(this._supabase);

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final session = _supabase.currentSession;
      if (session == null) return null;

      // Ambil data lengkap dari tabel app_users
      final response = await _supabase.client
          .from('app_users')
          .select()
          .eq('id_user', session.user.id)
          .single();

      return AppUserModel.fromSupabase(response);
    } catch (e) {
      return null;
    }
  }

  @override
Future<AppUser> login(String email, String password) async {
  try {
    // 1. Login ke Supabase Auth
    final response = await _supabase.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login gagal: User tidak ditemukan');
    }

    // 2. Ambil data lengkap dari tabel app_users
    final userData = await _supabase.client
        .from('app_users')
        .select()
        .eq('id_user', response.user!.id)
        .single();

    final appUser = AppUserModel.fromSupabase(userData);
    
    // 3. [PENTING] Update metadata dengan role untuk digunakan oleh currentUserRole
    await _supabase.client.auth.updateUser(
      UserAttributes(
        data: {
          'role': appUser.role,
          'display_name': appUser.displayName,
        },
      ),
    );

    // 4. Simpan ke SessionManager lokal
    await SessionManager().saveSession(
      appUser.id,
      appUser.role,
      appUser.email,
    );

    return appUser;
    
  } on AuthException catch (e) {
    throw Exception(_getAuthErrorMessage(e.message));
  } catch (e) {
    throw Exception('Terjadi kesalahan saat login: $e');
  }
}

  @override
  Future<void> logout() async {
    try {
      await _supabase.client.auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  // Session management
  Future<void> refreshSession() async {
    try {
      await _supabase.client.auth.refreshSession();
    } catch (e) {
      throw Exception('Session expired');
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  String _getAuthErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi';
    }
    return error;
  }
}