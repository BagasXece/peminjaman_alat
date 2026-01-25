// lib/presentation/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/dummy_data.dart';
import '../../domain/entities/alat.dart';
import '../../domain/entities/app_user.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

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
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Laporan'),
  ];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      // Desktop: NavigationRail di kiri
      // Mobile: Drawer menu dari kiri
      drawer: isDesktop ? null : _buildMobileDrawer(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      // Mobile: BottomNavigationBar
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileDrawer() {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary700, AppColors.primary600],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.build_circle, color: Colors.white, size: 32),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administrator Panel',
                    style: AppTypography.bodyLarge.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          user.email,
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? AppColors.primary600 : AppColors.neutral600,
                  ),
                  title: Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary600 : AppColors.neutral900,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primary50,
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          // Logout
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.danger600),
            title: Text('Keluar', style: TextStyle(color: AppColors.danger600)),
            onTap: _confirmLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        // Mobile App Bar
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
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
                  colors: [AppColors.primary700, AppColors.primary600],
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
                        'Dashboard Admin',
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola sistem peminjaman alat',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: _buildContent(),
        ),
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

  // ==================== DESKTOP LAYOUT ====================

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar Navigation Rail
        NavigationRail(
          extended: MediaQuery.of(context).size.width > 1200,
          minExtendedWidth: 200,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.build_circle, color: AppColors.primary600, size: 32),
                ),
                const SizedBox(height: 8),
                if (MediaQuery.of(context).size.width > 1200)
                  Text(AppConstants.appName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.logout, color: AppColors.danger600),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
          destinations: _navItems.map((item) => NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon, color: AppColors.primary600),
            label: Text(item.label),
          )).toList(),
        ),
        // Main Content
        Expanded(
          child: Container(
            color: AppColors.neutral50,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  // ==================== CONTENT BUILDER ====================

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardOverview();
      case 1:
        return _UserManagement();
      case 2:
        return _KategoriManagement();
      case 3:
        return _AlatManagement();
      case 4:
        return _LaporanPage();
      default:
        return _DashboardOverview();
    }
  }
}

// Navigation Item Model
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ==================== DASHBOARD OVERVIEW (RESPONSIVE) ====================

class _DashboardOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 640;
    final crossAxisCount = isMobile ? 2 : (screenWidth > 1200 ? 4 : 2);

    final totalUsers = DummyData.users.length;
    final totalAlat = DummyData.alatList.length;
    final alatTersedia = DummyData.alatList.where((a) => a.status == 'tersedia').length;
    final alatDipinjam = DummyData.alatList.where((a) => a.status == 'dipinjam').length;
    final totalPeminjaman = DummyData.peminjamanList.length;
    final peminjamanAktif = DummyData.peminjamanList.where((p) => p.status == 'disetujui' || p.status == 'sebagian').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Desktop only, mobile di AppBar)
          if (!isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Admin', style: AppTypography.h2),
                    const SizedBox(height: 4),
                    Text('Overview sistem peminjaman alat', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500)),
                  ],
                ),
                Chip(
                  avatar: Icon(Icons.admin_panel_settings, size: 18, color: AppColors.primary600),
                  label: Text('Administrator'),
                  backgroundColor: AppColors.primary50,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Stats Grid - Responsive
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.2 : 1.5,
            children: [
              _StatCard(
                title: 'Total Users',
                value: totalUsers.toString(),
                subtitle: '${DummyData.users.where((u) => u.role == 'peminjam').length} Peminjam',
                icon: Icons.people,
                color: AppColors.primary600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Total Alat',
                value: totalAlat.toString(),
                subtitle: '$alatTersedia Tersedia',
                icon: Icons.build,
                color: AppColors.secondary600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Peminjaman Aktif',
                value: peminjamanAktif.toString(),
                subtitle: 'Dari $totalPeminjaman total',
                icon: Icons.assignment,
                color: AppColors.info600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Denda Bulan Ini',
                value: 'Rp 15K',
                subtitle: '3 transaksi',
                icon: Icons.money_off,
                color: AppColors.danger600,
                isMobile: isMobile,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity & Quick Actions - Responsive
          isMobile 
            ? Column(
                children: [
                  _RecentActivityCard(),
                  const SizedBox(height: 16),
                  _QuickActionsCard(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _RecentActivityCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _QuickActionsCard()),
                ],
              ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isMobile;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withOpacity(0.05),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 24),
              ),
              if (!isMobile) Icon(Icons.arrow_forward, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value, 
                style: isMobile ? AppTypography.h3.copyWith(color: color) : AppTypography.h2.copyWith(color: color)
              ),
              const SizedBox(height: 4),
              Text(title, style: isMobile ? AppTypography.labelMedium : AppTypography.labelLarge),
              const SizedBox(height: 2),
              Text(
                subtitle, 
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aktivitas Terbaru', style: AppTypography.h4),
          const SizedBox(height: 16),
          ...DummyData.peminjamanList.take(5).map((p) => _ActivityItem(
            title: 'Peminjaman ${p.status}',
            subtitle: '${p.peminjam?.displayNameOrEmail} • ${p.totalItems} alat',
            time: DateFormat('dd MMM, HH:mm').format(p.createdAt),
            status: p.status,
          )).toList(),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primary50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aksi Cepat', style: AppTypography.h4),
          const SizedBox(height: 12),
          _QuickActionButton(icon: Icons.person_add, label: 'Tambah User', onTap: () {}),
          _QuickActionButton(icon: Icons.add_circle, label: 'Tambah Alat', onTap: () {}),
          _QuickActionButton(icon: Icons.category, label: 'Tambah Kategori', onTap: () {}),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          Text(time, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary600, size: 20),
      title: Text(label, style: AppTypography.bodyMedium),
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

// ==================== USER MANAGEMENT (RESPONSIVE) ====================

class _UserManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manajemen User', style: isMobile ? AppTypography.h3 : AppTypography.h2),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Tambah'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text('Tambah User'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
          if (isMobile) const SizedBox(height: 16),
          
          // Mobile: Card list, Desktop: Table
          isMobile 
            ? _UserListMobile()
            : _UserListDesktop(),
        ],
      ),
    );
  }
}

class _UserListMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: DummyData.users.map((user) => AppCard(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.primary100,
            child: Text(user.initials, style: TextStyle(fontSize: 12, color: AppColors.primary700)),
          ),
          title: Text(user.displayNameOrEmail, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.email, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 4),
              Chip(
                label: Text(user.role, style: AppTypography.labelSmall),
                backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                labelStyle: TextStyle(color: _getRoleColor(user.role)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Row(
                children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
              )),
              PopupMenuItem(value: 'delete', child: Row(
                children: [Icon(Icons.delete, size: 18, color: AppColors.danger600), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.danger600))],
              )),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return AppColors.danger600;
      case 'petugas': return AppColors.secondary600;
      case 'peminjam': return AppColors.info600;
      default: return AppColors.neutral600;
    }
  }
}

class _UserListDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('NAMA', style: AppTypography.labelMedium)),
                Expanded(flex: 2, child: Text('EMAIL', style: AppTypography.labelMedium)),
                Expanded(child: Text('ROLE', style: AppTypography.labelMedium)),
                Expanded(child: Text('AKSI', style: AppTypography.labelMedium)),
              ],
            ),
          ),
          Divider(height: 1),
          // List
          ...DummyData.users.map((user) => _UserListItem(user: user)).toList(),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final AppUser user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary100,
                  child: Text(user.initials, style: TextStyle(fontSize: 12, color: AppColors.primary700)),
                ),
                const SizedBox(width: 12),
                Text(user.displayNameOrEmail, style: AppTypography.bodyMedium),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(user.email, style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600))),
          Expanded(
            child: Chip(
              label: Text(user.role, style: AppTypography.labelSmall),
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              labelStyle: TextStyle(color: _getRoleColor(user.role)),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete, size: 20, color: AppColors.danger500), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return AppColors.danger600;
      case 'petugas': return AppColors.secondary600;
      case 'peminjam': return AppColors.info600;
      default: return AppColors.neutral600;
    }
  }
}

// ==================== KATEGORI MANAGEMENT (RESPONSIVE) ====================

class _KategoriManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manajemen Kategori', style: isMobile ? AppTypography.h3 : AppTypography.h2),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Tambah'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMobile)
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text('Tambah Kategori'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
          if (isMobile) const SizedBox(height: 16),
          
          isMobile 
            ? Column(
                children: [
                  _KategoriCardMobile(kode: 'BT', nama: 'Mesin Bubut', jumlahSub: 2),
                  _KategoriCardMobile(kode: 'FR', nama: 'Mesin Frais', jumlahSub: 2),
                  _KategoriCardMobile(kode: 'GR', nama: 'Mesin Gerinda', jumlahSub: 2),
                  _KategoriCardMobile(kode: 'UK', nama: 'Alat Ukur', jumlahSub: 4),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori Alat', style: AppTypography.h4),
                          const SizedBox(height: 16),
                          _KategoriItem(kode: 'BT', nama: 'Mesin Bubut', jumlahSub: 2),
                          _KategoriItem(kode: 'FR', nama: 'Mesin Frais', jumlahSub: 2),
                          _KategoriItem(kode: 'GR', nama: 'Mesin Gerinda', jumlahSub: 2),
                          _KategoriItem(kode: 'UK', nama: 'Alat Ukur', jumlahSub: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sub Kategori', style: AppTypography.h4),
                          const SizedBox(height: 16),
                          _SubKategoriItem(kode: 'BT-CNC', nama: 'Bubut CNC', stok: 4),
                          _SubKategoriItem(kode: 'BT-MNL', nama: 'Bubut Manual', stok: 3),
                          _SubKategoriItem(kode: 'FR-VRT', nama: 'Frais Vertikal', stok: 3),
                          _SubKategoriItem(kode: 'GR-SFC', nama: 'Gerinda Surface', stok: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

class _KategoriCardMobile extends StatelessWidget {
  final String kode;
  final String nama;
  final int jumlahSub;

  const _KategoriCardMobile({
    required this.kode,
    required this.nama,
    required this.jumlahSub,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary100,
          child: Text(kode, style: TextStyle(fontSize: 10, color: AppColors.primary700)),
        ),
        title: Text(nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('$jumlahSub sub kategori', style: AppTypography.bodySmall),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Row(
              children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
            )),
            PopupMenuItem(value: 'delete', child: Row(
              children: [Icon(Icons.delete, size: 18, color: AppColors.danger600), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.danger600))],
            )),
          ],
        ),
      ),
    );
  }
}

class _KategoriItem extends StatelessWidget {
  final String kode;
  final String nama;
  final int jumlahSub;

  const _KategoriItem({
    required this.kode,
    required this.nama,
    required this.jumlahSub,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary100,
        child: Text(kode, style: TextStyle(fontSize: 10, color: AppColors.primary700)),
      ),
      title: Text(nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text('$jumlahSub sub kategori', style: AppTypography.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete, size: 20, color: AppColors.danger500), onPressed: () {}),
        ],
      ),
    );
  }
}

class _SubKategoriItem extends StatelessWidget {
  final String kode;
  final String nama;
  final int stok;

  const _SubKategoriItem({
    required this.kode,
    required this.nama,
    required this.stok,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.secondary100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(kode, style: TextStyle(fontSize: 10, color: AppColors.secondary700, fontWeight: FontWeight.bold)),
      ),
      title: Text(nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text('Stok: $stok unit', style: AppTypography.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete, size: 20, color: AppColors.danger500), onPressed: () {}),
        ],
      ),
    );
  }
}

// ==================== ALAT MANAGEMENT (RESPONSIVE) ====================

class _AlatManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manajemen Alat', style: isMobile ? AppTypography.h3 : AppTypography.h2),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Tambah'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search & Filter
          if (isMobile) ...[
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari alat...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text('Tambah Alat'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari alat...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: 'Semua Status',
                  items: ['Semua Status', 'Tersedia', 'Dipinjam', 'Nonaktif']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // List
          isMobile
            ? Column(
                children: DummyData.alatList.take(10).map((alat) => _AlatCardMobile(alat: alat)).toList(),
              )
            : AppCard(
                child: Column(
                  children: DummyData.alatList.take(10).map((alat) => _AlatListItem(alat: alat)).toList(),
                ),
              ),
        ],
      ),
    );
  }
}

class _AlatCardMobile extends StatelessWidget {
  final Alat alat;

  const _AlatCardMobile({required this.alat});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alat.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    Text(alat.kode, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
              StatusBadge(status: alat.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: AppColors.neutral500),
              const SizedBox(width: 8),
              Text(alat.namaKategori ?? '-', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit, size: 18),
                label: Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.delete, size: 18, color: AppColors.danger600),
                label: Text('Hapus', style: TextStyle(color: AppColors.danger600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlatListItem extends StatelessWidget {
  final Alat alat;

  const _AlatListItem({required this.alat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.precision_manufacturing, color: AppColors.primary600),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alat.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(alat.kode, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          Expanded(child: Text(alat.namaKategori ?? '-', style: AppTypography.bodySmall)),
          Expanded(child: StatusBadge(status: alat.status)),
          Row(
            children: [
              IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
              IconButton(icon: Icon(Icons.delete, size: 20, color: AppColors.danger500), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== LAPORAN (RESPONSIVE) ====================

class _LaporanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Laporan & Statistik', style: isMobile ? AppTypography.h3 : AppTypography.h2),
          const SizedBox(height: 24),
          
          // Chart Placeholder
          AppCard(
            child: Container(
              height: isMobile ? 200 : 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: isMobile ? 48 : 64, color: AppColors.neutral300),
                    const SizedBox(height: 16),
                    Text('Grafik Peminjaman', style: AppTypography.h4),
                    const SizedBox(height: 8),
                    Text('(Integrasi chart library)', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          isMobile
            ? Column(
                children: [
                  _RankingCard(
                    title: 'Peminjaman Terbanyak',
                    items: [
                      _RankingItem(rank: 1, name: 'Mesin Bubut CNC', count: 45),
                      _RankingItem(rank: 2, name: 'Digital Caliper', count: 38),
                      _RankingItem(rank: 3, name: 'Gerinda Surface', count: 32),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _RankingCard(
                    title: 'Peminjam Aktif',
                    items: [
                      _RankingItem(rank: 1, name: 'Dewi Mahasiswa', count: 12),
                      _RankingItem(rank: 2, name: 'Rudi Siswa', count: 8),
                      _RankingItem(rank: 3, name: 'Ahmad Petugas', count: 5),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _RankingCard(
                      title: 'Peminjaman Terbanyak',
                      items: [
                        _RankingItem(rank: 1, name: 'Mesin Bubut CNC', count: 45),
                        _RankingItem(rank: 2, name: 'Digital Caliper', count: 38),
                        _RankingItem(rank: 3, name: 'Gerinda Surface', count: 32),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RankingCard(
                      title: 'Peminjam Aktif',
                      items: [
                        _RankingItem(rank: 1, name: 'Dewi Mahasiswa', count: 12),
                        _RankingItem(rank: 2, name: 'Rudi Siswa', count: 8),
                        _RankingItem(rank: 3, name: 'Ahmad Petugas', count: 5),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final String title;
  final List<_RankingItem> items;

  const _RankingCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.rank == 1 ? AppColors.secondary500 : AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${item.rank}',
                      style: TextStyle(
                        color: item.rank == 1 ? Colors.white : AppColors.neutral700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.name, style: AppTypography.bodyMedium)),
                Text('${item.count}x', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _RankingItem {
  final int rank;
  final String name;
  final int count;

  _RankingItem({
    required this.rank,
    required this.name,
    required this.count,
  });
}