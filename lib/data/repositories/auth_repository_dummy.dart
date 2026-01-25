// lib/data/repositories/auth_repository_dummy.dart
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'dummy_data.dart';

class AuthRepositoryDummy implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulasi network
    return _currentUser;
  }

  @override
  Future<AppUser> login(String email, String password, String role) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    // Cari user dengan role yang sesuai
    final user = DummyData.users.firstWhere(
      (u) => u.email == email && u.role == role,
      orElse: () => throw Exception('User tidak ditemukan atau role tidak sesuai'),
    );
    
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    _currentUser = null;
  }
}