// lib/domain/entities/app_user.dart
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String role; // admin, petugas, peminjam
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }

  String get displayNameOrEmail => displayName ?? email.split('@').first;
}