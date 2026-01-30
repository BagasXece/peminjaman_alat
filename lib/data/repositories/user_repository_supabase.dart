import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/supabase_client.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

abstract class UserRepository {
  Future<List<AppUser>> getAllUsers();
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });
  Future<void> deleteUser(String userId);
  Future<AppUser> updateUser(String userId, {
    String? displayName,
    String? role,
  });
}

class UserRepositorySupabase implements UserRepository {
  final SupabaseService _supabase;

  UserRepositorySupabase(this._supabase);

  @override
  Future<List<AppUser>> getAllUsers() async {
    try {
      // Validasi: hanya admin yang boleh melihat semua user
      if (_supabase.currentUserRole != 'admin') {
        throw Exception('Unauthorized: Hanya admin yang dapat melihat daftar user');
      }

      final response = await _supabase.client
          .from('app_users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AppUserModel.fromSupabase(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat user: ${e.message}');
    }
  }

  @override
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      // Validasi: hanya admin yang boleh membuat user
      if (_supabase.currentUserRole != 'admin') {
        throw Exception('Unauthorized: Hanya admin yang dapat membuat user');
      }

      // Panggil Edge Function create-user
      final response = await _supabase.client.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'display_name': displayName,
          'role': role,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Unknown error';
        throw Exception('Gagal membuat user: $error');
      }

      // Ambil data user yang baru dibuat dari tabel app_users
      // Trigger handle_new_user sudah membuat record ini
      final newUserEmail = response.data['user']['email'];
      await Future.delayed(Duration(milliseconds: 500)); // Tunggu trigger jalan
      
      final userData = await _supabase.client
          .from('app_users')
          .select()
          .eq('email', newUserEmail)
          .single();

      return AppUserModel.fromSupabase(userData);
      
    } catch (e) {
      throw Exception('Gagal membuat user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // Validasi: hanya admin yang boleh menghapus
      if (_supabase.currentUserRole != 'admin') {
        throw Exception('Unauthorized');
      }

      // Hapus dari auth (cascade ke app_users karena FK)
      await _supabase.client.auth.admin.deleteUser(userId);
      
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  @override
  Future<AppUser> updateUser(String userId, {
    String? displayName,
    String? role,
  }) async {
    try {
      // Validasi: hanya admin yang boleh update
      if (_supabase.currentUserRole != 'admin') {
        throw Exception('Unauthorized');
      }

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (role != null) updates['role'] = role;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.client
          .from('app_users')
          .update(updates)
          .eq('id_user', userId)
          .select()
          .single();

      return AppUserModel.fromSupabase(response);
      
    } catch (e) {
      throw Exception('Gagal update user: $e');
    }
  }
}