// lib/core/network/supabase_client.dart

import 'package:peminjaman_alat/core/services/session_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;
  
  factory SupabaseService() => _instance;
  
  SupabaseService._internal() {
    client = Supabase.instance.client;
  }
  
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  Session? get currentSession => client.auth.currentSession;
  
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // [PERBAIKAN] Priority: Auth Metadata > SessionManager > null
  String? get currentUserRole {
    // Coba ambil dari metadata dulu
    final metadataRole = client.auth.currentUser?.userMetadata?['role'] as String?;
    if (metadataRole != null) return metadataRole;
    
    // Fallback ke SessionManager
    final sessionRole = SessionManager().userRole;
    if (sessionRole != null) return sessionRole;
    
    return null;
  }
  
  // Helper untuk cek apakah user adalah admin
  bool get isAdmin => currentUserRole == 'admin';
  
  Future<Map<String, dynamic>?> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(
        functionName,
        params: params ?? {},
      );
      
      if (response is Map<String, dynamic>) return response;
      if (response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    }
  }
}