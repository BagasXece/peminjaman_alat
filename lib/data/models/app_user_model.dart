import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.role,
    required super.createdAt,
  });

  // Mapping dari Supabase (tabel app_users)
  factory AppUserModel.fromSupabase(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id_user'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      role: json['role'] as String? ?? 'peminjam',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Mapping dari Supabase Auth metadata
  factory AppUserModel.fromAuthMetadata(String id, String email, Map<String, dynamic> metadata) {
    return AppUserModel(
      id: id,
      email: email,
      displayName: metadata['display_name'] as String?,
      role: metadata['role'] as String? ?? 'peminjam',
      createdAt: DateTime.now(),
    );
  }
}