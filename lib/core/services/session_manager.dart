import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  late final SharedPreferences _prefs;
  
  factory SessionManager() => _instance;
  
  SessionManager._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Simpan session lokal
  Future<void> saveSession(String userId, String role, String email) async {
    await _prefs.setString('user_id', userId);
    await _prefs.setString('user_role', role);
    await _prefs.setString('user_email', email);
    await _prefs.setBool('is_logged_in', true);
    await _prefs.setString('last_login', DateTime.now().toIso8601String());
  }

  // Ambil data session
  String? get userId => _prefs.getString('user_id');
  String? get userRole => _prefs.getString('user_role');
  String? get userEmail => _prefs.getString('user_email');
  bool get isLoggedIn => _prefs.getBool('is_logged_in') ?? false;

  // Cek privilege
  bool get isAdmin => userRole == 'admin';
  bool get isPetugas => userRole == 'petugas';
  bool get isPeminjam => userRole == 'peminjam';
  
  bool get canManageUsers => isAdmin;
  bool get canApprovePeminjaman => isAdmin || isPetugas;
  bool get canProcessReturn => isAdmin || isPetugas;

  // Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove('user_id');
    await _prefs.remove('user_role');
    await _prefs.remove('user_email');
    await _prefs.setBool('is_logged_in', false);
    await _prefs.remove('last_login');
  }

  // Cek session valid (tidak expired)
  bool isSessionValid() {
    if (!isLoggedIn) return false;
    final lastLogin = _prefs.getString('last_login');
    if (lastLogin == null) return false;
    
    final lastLoginTime = DateTime.parse(lastLogin);
    final difference = DateTime.now().difference(lastLoginTime);
    // Session berlaku 24 jam
    return difference.inHours < 24;
  }
}