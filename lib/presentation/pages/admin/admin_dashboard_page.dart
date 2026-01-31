// lib/presentation/pages/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peminjaman_alat/core/network/supabase_client.dart';
import 'package:peminjaman_alat/data/repositories/peminjaman_repository_supabase.dart';
import 'package:peminjaman_alat/presentation/blocs/auth/auth_state.dart';
import 'package:peminjaman_alat/presentation/blocs/peminjaman/peminjaman_admin_cubit.dart';
import 'package:peminjaman_alat/presentation/pages/admin/user_management_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../widgets/role_guard.dart';
import 'alat_management_page.dart';
import 'kategori_management_page.dart';
import 'peminjaman_list_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Users'),
    _NavItem(icon: Icons.category_outlined, activeIcon: Icons.category, label: 'Kategori'),
    _NavItem(icon: Icons.build_outlined, activeIcon: Icons.build, label: 'Alat'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Peminjaman'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Laporan'),
  ];

  // Helper untuk mendapatkan judul berdasarkan index
  String get _currentTitle => _navItems[_selectedIndex].label;
  
  // Helper untuk mendapatkan subtitle berdasarkan index
  String get _currentSubtitle {
    switch (_selectedIndex) {
      case 0:
        return 'Ringkasan sistem peminjaman';
      case 1:
        return 'Kelola pengguna sistem';
      case 2:
        return 'Kelola kategori alat';
      case 3:
        return 'Kelola data alat';
      case 4:
        return 'Kelola peminjaman';
      case 5:
        return 'Lihat laporan sistem';
      default:
        return 'Kelola sistem peminjaman alat';
    }
  }

  // Helper untuk mendapatkan warna tema berdasarkan index (opsional)
  Color get _currentColor {
    switch (_selectedIndex) {
      case 0:
        return AppColors.primary700;
      case 1:
        return AppColors.info700;
      case 2:
        return AppColors.secondary700;
      case 3:
        return AppColors.success700;
      case 4:
        return AppColors.warning700;
      case 5:
        return AppColors.danger700;
      default:
        return AppColors.primary700;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Keluar'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Layout sama untuk mobile dan desktop - menggunakan bottom nav untuk semua
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: AppColors.danger600),
              onPressed: _confirmLogout,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_currentColor, _currentColor.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _currentTitle, 
                        style: AppTypography.h3.copyWith(color: Colors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentSubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary600,
      unselectedItemColor: AppColors.neutral500,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
      items: _navItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon),
        label: item.label,
      )).toList(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardOverview();
      case 1:
        return RoleGuard(
        allowedRoles: ['admin'],
        child: BlocProvider.value(
          value: context.read<UserCubit>()..loadUsers(),
          child: const UserManagementPage(),
        ),
      );
      case 2:
        return const KategoriManagementPage();
      case 3:
        return const AlatManagementPage();
      case 4:
        return BlocProvider(
          create: (context) => PeminjamanAdminCubit(
            PeminjamanRepositorySupabase(SupabaseService()),
          )..loadPeminjaman(),
          child: const PeminjamanListPage(),
        );
      case 5:
        return _LaporanPage();
      default:
        return _DashboardOverview();
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// Dashboard Overview tetap di file ini atau bisa dipisah juga
class _DashboardOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dashboard Overview - Implementasi terpisah'));
  }
}

class _LaporanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Laporan Page - Implementasi terpisah'));
  }
}