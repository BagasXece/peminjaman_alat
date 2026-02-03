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
  Future<AppUser> updateUser(
    String userId, {
    String? email,
    String? password,
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
      // Ambil langsung dari tabel (bisa juga via Edge Function kalau ada filtering kompleks)
      final response = await _supabase.client
          .from('app_users')
          .select()
          .isFilter('deleted_at', null) // Filter soft delete
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

      // Ambil data user yang baru dibuat
      await Future.delayed(Duration(milliseconds: 500)); // Tunggu trigger

      final userData = await _supabase.client
          .from('app_users')
          .select()
          .eq('email', email)
          .single();

      return AppUserModel.fromSupabase(userData);
    } on FunctionException catch (e) {
      throw Exception('Edge Function Error: ${e.details}');
    } catch (e) {
      throw Exception('Gagal membuat user: $e');
    }
  }

  @override
  Future<AppUser> updateUser(
    String userId, {
    String? email,
    String? password,
    String? displayName,
    String? role,
  }) async {
    try {
      final response = await _supabase.client.functions.invoke(
        'update-user',
        body: {
          'user_id': userId,
          'updates': {
            if (email != null) 'email': email,
            if (password != null) 'password': password,
            if (displayName != null) 'display_name': displayName,
            if (role != null) 'role': role,
          },
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Unknown error';
        throw Exception('Gagal update user: $error');
      }

      // Return data dari response Edge Function (sudah include app_user)
      final appUserData = response.data['app_user'];
      if (appUserData != null) {
        return AppUserModel.fromSupabase(appUserData);
      }

      // Fallback: fetch ulang dari tabel
      final userData = await _supabase.client
          .from('app_users')
          .select()
          .eq('id_user', userId)
          .single();

      return AppUserModel.fromSupabase(userData);
    } on FunctionException catch (e) {
      throw Exception('Gagal update user: ${e.details}');
    } catch (e) {
      throw Exception('Gagal update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // [PILIHAN 1] Soft Delete via Edge Function (Rekomendasi)
      final response = await _supabase.client.functions.invoke(
        'delete-user', // Anda perlu buat edge function ini juga
        body: {'user_id': userId},
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Unknown error';
        throw Exception('Gagal hapus user: $error');
      }

      // [PILIHAN 2] Soft Delete langsung (tanpa edge function)
      // await _supabase.client
      //     .from('app_users')
      //     .update({'deleted_at': DateTime.now().toIso8601String()})
      //     .eq('id_user', userId);
    } on FunctionException catch (e) {
      throw Exception('Gagal menghapus user: ${e.details}');
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }
}
