import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;
  
  factory SupabaseService() => _instance;
  
  SupabaseService._internal() {
    client = Supabase.instance.client;
  }
  
  //current user info
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;
  Session? get currentSession => client.auth.currentSession;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Helper untuk RPC calls
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
  
  // Check current user role from metadata
  String? get currentUserRole {
    return client.auth.currentUser?.userMetadata?['role'] as String?;
  }
}