// lib/presentation/blocs/dashboard/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/core/network/supabase_client.dart';

// ... states tetap sama ...

class DashboardCubit extends Cubit<DashboardState> {
  final SupabaseService _supabaseService;

  DashboardCubit(this._supabaseService) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _fetchAlatStats(),
        _fetchPeminjamanStats(),
        _fetchUserStats(),
        _fetchRecentActivities(),
      ]);

      final alatStats = results[0] as Map<String, dynamic>;
      final peminjamanStats = results[1] as Map<String, dynamic>;
      final userStats = results[2] as Map<String, dynamic>;
      final activities = results[3] as List<RecentActivity>;

      emit(DashboardLoaded(DashboardStats(
        totalAlat: alatStats['total'] ?? 0,
        alatTersedia: alatStats['tersedia'] ?? 0,
        alatDipinjam: alatStats['dipinjam'] ?? 0,
        alatTidakTersedia: alatStats['tidak_tersedia'] ?? 0,
        totalPeminjaman: peminjamanStats['total'] ?? 0,
        peminjamanMenunggu: peminjamanStats['menunggu'] ?? 0,
        peminjamanDisetujui: peminjamanStats['disetujui'] ?? 0,
        peminjamanSelesai: peminjamanStats['selesai'] ?? 0,
        totalUsers: userStats['total'] ?? 0,
        totalPetugas: userStats['petugas'] ?? 0,
        recentActivities: activities,
      )));
    } catch (e) {
      emit(DashboardError('Gagal memuat data dashboard: ${e.toString()}'));
    }
  }

  Future<Map<String, dynamic>> _fetchAlatStats() async {
    try {
      final response = await _supabaseService.client
          .from('alat')
          .select('status')
          .filter('deleted_at', 'is', null);
      
      final data = response as List<dynamic>;
      return {
        'total': data.length,
        'tersedia': data.where((a) => a['status'] == 'tersedia').length,
        'dipinjam': data.where((a) => a['status'] == 'dipinjam').length,
        'tidak_tersedia': data.where((a) => a['status'] == 'tidak_tersedia').length,
      };
    } catch (e) {
      return {'total': 0, 'tersedia': 0, 'dipinjam': 0, 'tidak_tersedia': 0};
    }
  }

  Future<Map<String, dynamic>> _fetchPeminjamanStats() async {
    try {
      final response = await _supabaseService.client
          .from('peminjaman')
          .select('status');
      
      final data = response as List<dynamic>;
      return {
        'total': data.length,
        'menunggu': data.where((p) => p['status'] == 'menunggu').length,
        'disetujui': data.where((p) => p['status'] == 'disetujui' || p['status'] == 'sebagian').length,
        'selesai': data.where((p) => p['status'] == 'selesai').length,
      };
    } catch (e) {
      return {'total': 0, 'menunggu': 0, 'disetujui': 0, 'selesai': 0};
    }
  }

  Future<Map<String, dynamic>> _fetchUserStats() async {
    try {
      final response = await _supabaseService.client
          .from('app_users')
          .select('role')
          .filter('deleted_at', 'is', null);
      
      final data = response as List<dynamic>;
      return {
        'total': data.length,
        'petugas': data.where((u) => u['role'] == 'petugas' || u['role'] == 'admin').length,
      };
    } catch (e) {
      return {'total': 0, 'petugas': 0};
    }
  }

  Future<List<RecentActivity>> _fetchRecentActivities() async {
    try {
      final response = await _supabaseService.client
          .from('peminjaman')
          .select('''
            id,
            kode_peminjaman,
            status,
            created_at,
            users (display_name, email)
          ''')
          .order('created_at', ascending: false)
          .limit(5);

      return (response as List<dynamic>).map((item) {
        final user = item['users'] as Map<String, dynamic>?;
        final type = item['status'] == 'selesai' ? 'pengembalian' : 'peminjaman';
        return RecentActivity(
          id: item['id'].toString(),
          type: type,
          title: user?['display_name'] ?? user?['email'] ?? 'Unknown',
          subtitle: item['kode_peminjaman'] ?? '-',
          timestamp: DateTime.parse(item['created_at']),
          status: item['status'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

class DashboardStats {
  final int totalAlat;
  final int alatTersedia;
  final int alatDipinjam;
  final int alatTidakTersedia;
  final int totalPeminjaman;
  final int peminjamanMenunggu;
  final int peminjamanDisetujui;
  final int peminjamanSelesai;
  final int totalUsers;
  final int totalPetugas;
  final List<RecentActivity> recentActivities;

  DashboardStats({
    required this.totalAlat,
    required this.alatTersedia,
    required this.alatDipinjam,
    required this.alatTidakTersedia,
    required this.totalPeminjaman,
    required this.peminjamanMenunggu,
    required this.peminjamanDisetujui,
    required this.peminjamanSelesai,
    required this.totalUsers,
    required this.totalPetugas,
    required this.recentActivities,
  });
}

class RecentActivity {
  final String id;
  final String type; // 'peminjaman', 'pengembalian', 'user_baru'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String status;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.status,
  });
}

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  DashboardLoaded(this.stats);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}