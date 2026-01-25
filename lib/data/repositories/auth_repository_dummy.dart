// lib/data/repositories/auth_repository_dummy.dart
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'dummy_data.dart';

class AuthRepositoryDummy implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    // Cari user berdasarkan email (case insensitive)
    final normalizedEmail = email.toLowerCase().trim();
    
    try {
      final user = DummyData.users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      
      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception(
        'Email tidak ditemukan.\n\n'
        'Akun demo yang tersedia:\n'
        '• mahasiswa1@student.ac.id (Peminjam)\n'
        '• mahasiswa2@student.ac.id (Peminjam)\n'
        '• petugas1@mesin.ac.id (Petugas)\n'
        '• petugas2@mesin.ac.id (Petugas)\n'
        '• admin@mesin.ac.id (Admin)'
      );
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    _currentUser = null;
  }
}