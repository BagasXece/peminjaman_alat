// lib/domain/repositories/auth_repository.dart

import 'package:peminjaman_alat/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> login(String email, String password, String role);
  Future<void> logout();
}