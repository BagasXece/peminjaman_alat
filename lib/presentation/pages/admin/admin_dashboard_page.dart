// lib/presentation/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/dummy_data.dart';
import '../../../domain/entities/alat.dart';
import '../../../domain/entities/app_user.dart';
import '../../blocs/auth_cubit.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Users',
    ),
    _NavItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      label: 'Kategori',
    ),
    _NavItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      label: 'Alat',
    ),
    _NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Laporan',
    ),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Keluar'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
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
      // drawer: isDesktop ? null : _buildMobileDrawer(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      // Mobile: BottomNavigationBar
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  // ==================== MOBILE LAYOUT ====================

  // Widget _buildMobileDrawer() {
  //   final user = (context.read<AuthCubit>().state as Authenticated).user;

  //   return Drawer(
  //     child: Column(
  //       children: [
  //         // Drawer Header
  //         Container(
  //           padding: const EdgeInsets.all(24),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [AppColors.primary700, AppColors.primary600],
  //             ),
  //           ),
  //           child: SafeArea(
  //             bottom: false,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(0.2),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Icon(
  //                         Icons.build_circle,
  //                         color: Colors.white,
  //                         size: 32,
  //                       ),
  //                     ),
  //                     const Spacer(),
  //                     IconButton(
  //                       icon: Icon(Icons.close, color: Colors.white),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 24),
  //                 Text(
  //                   AppConstants.appName,
  //                   style: AppTypography.h3.copyWith(color: Colors.white),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'Administrator Panel',
  //                   style: AppTypography.bodyLarge.copyWith(
  //                     color: Colors.white.withOpacity(0.8),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 8,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withOpacity(0.15),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.admin_panel_settings,
  //                         color: Colors.white,
  //                         size: 16,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         user.email,
  //                         style: AppTypography.bodyMedium.copyWith(
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         // Menu Items
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: _navItems.length,
  //             itemBuilder: (context, index) {
  //               final item = _navItems[index];
  //               final isSelected = _selectedIndex == index;
  //               return ListTile(
  //                 leading: Icon(
  //                   isSelected ? item.activeIcon : item.icon,
  //                   color: isSelected
  //                       ? AppColors.primary600
  //                       : AppColors.neutral600,
  //                 ),
  //                 title: Text(
  //                   item.label,
  //                   style: AppTypography.bodyMedium.copyWith(
  //                     color: isSelected
  //                         ? AppColors.primary600
  //                         : AppColors.neutral900,
  //                     fontWeight: isSelected
  //                         ? FontWeight.w600
  //                         : FontWeight.normal,
  //                   ),
  //                 ),
  //                 selected: isSelected,
  //                 selectedTileColor: AppColors.primary50,
  //                 onTap: () {
  //                   setState(() => _selectedIndex = index);
  //                   Navigator.pop(context);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         // Logout
  //         Divider(),
  //         ListTile(
  //           leading: Icon(Icons.logout, color: AppColors.danger600),
  //           title: Text('Keluar', style: TextStyle(color: AppColors.danger600)),
  //           onTap: _confirmLogout,
  //         ),
  //         const SizedBox(height: 16),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        // Mobile App Bar
        SliverAppBar(
          expandedHeight: 140,
          floating: false,
          pinned: true,
          elevation: 0,

          // leading: Builder(
          //   builder: (context) => IconButton(
          //     icon: Icon(Icons.menu),
          //     onPressed: () => Scaffold.of(context).openDrawer(),
          //   ),
          // ),
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
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Content
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
      items: _navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            ),
          )
          .toList(),
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
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
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
                  child: Icon(
                    Icons.build_circle,
                    color: AppColors.primary600,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                if (MediaQuery.of(context).size.width > 1200)
                  Text(
                    AppConstants.appName,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.logout, color: AppColors.danger600),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
          destinations: _navItems
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(
                    item.activeIcon,
                    color: AppColors.primary600,
                  ),
                  label: Text(item.label),
                ),
              )
              .toList(),
        ),
        // Main Content
        Expanded(
          child: Container(color: AppColors.neutral50, child: _buildContent()),
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
    final alatTersedia = DummyData.alatList
        .where((a) => a.status == 'tersedia')
        .length;
    final alatDipinjam = DummyData.alatList
        .where((a) => a.status == 'dipinjam')
        .length;
    final totalPeminjaman = DummyData.peminjamanList.length;
    final peminjamanAktif = DummyData.peminjamanList
        .where((p) => p.status == 'disetujui' || p.status == 'sebagian')
        .length;

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
                    Text(
                      'Overview sistem peminjaman alat',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
                Chip(
                  avatar: Icon(
                    Icons.admin_panel_settings,
                    size: 18,
                    color: AppColors.primary600,
                  ),
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
                subtitle:
                    '${DummyData.users.where((u) => u.role == 'peminjam').length} Peminjam',
                icon: Icons.people,
                color: AppColors.primary600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Total Alat',
                value: totalAlat.toString(),
                subtitle: 'Keseluruhan Inventaris',
                icon: Icons.build,
                color: AppColors.secondary600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Alat Tersedia',
                value: alatTersedia.toString(),
                subtitle: 'Siap Pakai',
                icon: Icons.check_circle,
                color: AppColors.success600,
                isMobile: isMobile,
              ),
              _StatCard(
                title: 'Alat Dipinjam',
                value: alatDipinjam.toString(),
                subtitle: 'Dalam Peminjaman',
                icon: Icons.assignment_late,
                color: AppColors.warning600,
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
                style: isMobile
                    ? AppTypography.h3.copyWith(color: color)
                    : AppTypography.h2.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: isMobile
                    ? AppTypography.labelMedium
                    : AppTypography.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
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
          ...DummyData.peminjamanList
              .take(5)
              .map(
                (p) => _ActivityItem(
                  title: 'Peminjaman ${p.status}',
                  subtitle:
                      '${p.peminjam?.displayNameOrEmail} • ${p.totalItems} alat',
                  time: DateFormat('dd MMM, HH:mm').format(p.createdAt),
                  status: p.status,
                ),
              )
              .toList(),
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
          _QuickActionButton(
            icon: Icons.person_add,
            label: 'Tambah User',
            onTap: () {},
          ),
          _QuickActionButton(
            icon: Icons.add_circle,
            label: 'Tambah Alat',
            onTap: () {},
          ),
          _QuickActionButton(
            icon: Icons.category,
            label: 'Tambah Kategori',
            onTap: () {},
          ),
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
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral400,
            ),
          ),
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
              Text(
                'Manajemen User',
                style: isMobile ? AppTypography.h3 : AppTypography.h2,
              ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          if (isMobile) const SizedBox(height: 16),

          // Mobile: Card list, Desktop: Table
          isMobile ? _UserListMobile() : _UserListDesktop(),
        ],
      ),
    );
  }
}

class _UserListMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: DummyData.users
          .map(
            (user) => AppCard(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    user.initials,
                    style: TextStyle(fontSize: 12, color: AppColors.primary700),
                  ),
                ),
                title: Text(
                  user.displayNameOrEmail,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(user.role, style: AppTypography.labelSmall),
                      backgroundColor: _getRoleColor(
                        user.role,
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(color: _getRoleColor(user.role)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: AppColors.danger600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.danger600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.danger600;
      case 'petugas':
        return AppColors.secondary600;
      case 'peminjam':
        return AppColors.info600;
      default:
        return AppColors.neutral600;
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
                Expanded(
                  flex: 2,
                  child: Text('NAMA', style: AppTypography.labelMedium),
                ),
                Expanded(
                  flex: 2,
                  child: Text('EMAIL', style: AppTypography.labelMedium),
                ),
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
                  child: Text(
                    user.initials,
                    style: TextStyle(fontSize: 12, color: AppColors.primary700),
                  ),
                ),
                const SizedBox(width: 12),
                Text(user.displayNameOrEmail, style: AppTypography.bodyMedium),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.email,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
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
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 20,
                    color: AppColors.danger500,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.danger600;
      case 'petugas':
        return AppColors.secondary600;
      case 'peminjam':
        return AppColors.info600;
      default:
        return AppColors.neutral600;
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
              Text(
                'Manajemen Kategori',
                style: isMobile ? AppTypography.h3 : AppTypography.h2,
              ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          if (isMobile) const SizedBox(height: 16),

          isMobile
              ? Column(
                  children: [
                    _KategoriCardMobile(
                      kode: 'BT',
                      nama: 'Mesin Bubut',
                      jumlahSub: 2,
                    ),
                    _KategoriCardMobile(
                      kode: 'FR',
                      nama: 'Mesin Frais',
                      jumlahSub: 2,
                    ),
                    _KategoriCardMobile(
                      kode: 'GR',
                      nama: 'Mesin Gerinda',
                      jumlahSub: 2,
                    ),
                    _KategoriCardMobile(
                      kode: 'UK',
                      nama: 'Alat Ukur',
                      jumlahSub: 4,
                    ),
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
                            _KategoriItem(
                              kode: 'BT',
                              nama: 'Mesin Bubut',
                              jumlahSub: 2,
                            ),
                            _KategoriItem(
                              kode: 'FR',
                              nama: 'Mesin Frais',
                              jumlahSub: 2,
                            ),
                            _KategoriItem(
                              kode: 'GR',
                              nama: 'Mesin Gerinda',
                              jumlahSub: 2,
                            ),
                            _KategoriItem(
                              kode: 'UK',
                              nama: 'Alat Ukur',
                              jumlahSub: 4,
                            ),
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
                            _SubKategoriItem(
                              kode: 'BT-CNC',
                              nama: 'Bubut CNC',
                              stok: 4,
                            ),
                            _SubKategoriItem(
                              kode: 'BT-MNL',
                              nama: 'Bubut Manual',
                              stok: 3,
                            ),
                            _SubKategoriItem(
                              kode: 'FR-VRT',
                              nama: 'Frais Vertikal',
                              stok: 3,
                            ),
                            _SubKategoriItem(
                              kode: 'GR-SFC',
                              nama: 'Gerinda Surface',
                              stok: 4,
                            ),
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
          child: Text(
            kode,
            style: TextStyle(fontSize: 10, color: AppColors.primary700),
          ),
        ),
        title: Text(
          nama,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$jumlahSub sub kategori',
          style: AppTypography.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppColors.danger600),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: AppColors.danger600)),
                ],
              ),
            ),
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
        child: Text(
          kode,
          style: TextStyle(fontSize: 10, color: AppColors.primary700),
        ),
      ),
      title: Text(
        nama,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$jumlahSub sub kategori', style: AppTypography.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
            onPressed: () {},
          ),
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
        child: Text(
          kode,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.secondary700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        nama,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Stok: $stok unit', style: AppTypography.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
            onPressed: () {},
          ),
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
              Text(
                'Manajemen Alat',
                style: isMobile ? AppTypography.h3 : AppTypography.h2,
              ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
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
                  children: DummyData.alatList
                      .take(10)
                      .map((alat) => _AlatCardMobile(alat: alat))
                      .toList(),
                )
              : AppCard(
                  child: Column(
                    children: DummyData.alatList
                        .take(10)
                        .map((alat) => _AlatListItem(alat: alat))
                        .toList(),
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
                    Text(
                      alat.nama,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      alat.kode,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
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
                label: Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.danger600),
                ),
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
            child: Icon(
              Icons.precision_manufacturing,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.nama,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  alat.kode,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              alat.namaKategori ?? '-',
              style: AppTypography.bodySmall,
            ),
          ),
          Expanded(child: StatusBadge(status: alat.status)),
          Row(
            children: [
              IconButton(icon: Icon(Icons.edit, size: 20), onPressed: () {}),
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== LAPORAN (RESPONSIVE) ====================

// ==================== LAPORAN ADMIN (DENGAN CETAK) ====================

class _LaporanPage extends StatefulWidget {
  @override
  State<_LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<_LaporanPage> {
  String _selectedLaporan = 'peminjaman';

  final List<Map<String, dynamic>> _laporanOptions = [
    {
      'id': 'peminjaman',
      'title': 'Laporan Peminjaman',
      'icon': Icons.assignment,
      'color': AppColors.info600,
      'desc': 'Ringkasan dan detail semua transaksi peminjaman',
    },
    {
      'id': 'pengembalian',
      'title': 'Laporan Pengembalian',
      'icon': Icons.assignment_return,
      'color': AppColors.success600,
      'desc': 'Status pengembalian alat dan keterlambatan',
    },
    {
      'id': 'denda',
      'title': 'Laporan Denda',
      'icon': Icons.money_off,
      'color': AppColors.danger600,
      'desc': 'Rekapitulasi denda dari peminjaman terlambat',
    },
    {
      'id': 'alat',
      'title': 'Laporan Inventaris Alat',
      'icon': Icons.build,
      'color': AppColors.secondary600,
      'desc': 'Status dan kondisi seluruh alat',
    },
    {
      'id': 'user',
      'title': 'Laporan Aktivitas User',
      'icon': Icons.people,
      'color': AppColors.primary600,
      'desc': 'Aktivitas peminjam dan petugas',
    },
    {
      'id': 'audit',
      'title': 'Laporan Audit Sistem',
      'icon': Icons.security,
      'color': AppColors.neutral700,
      'desc': 'Log perubahan dan aktivitas kritis',
    },
  ];

  void _generateLaporan(String laporanId) {
    switch (laporanId) {
      case 'peminjaman':
        _showLaporanPreview('Laporan Peminjaman', _buildLaporanPeminjaman());
        break;
      case 'pengembalian':
        _showLaporanPreview(
          'Laporan Pengembalian',
          _buildLaporanPengembalian(),
        );
        break;
      case 'denda':
        _showLaporanPreview('Laporan Denda', _buildLaporanDenda());
        break;
      case 'alat':
        _showLaporanPreview('Laporan Inventaris Alat', _buildLaporanAlat());
        break;
      case 'user':
        _showLaporanPreview('Laporan Aktivitas User', _buildLaporanUser());
        break;
      case 'audit':
        _showLaporanPreview('Laporan Audit Sistem', _buildLaporanAudit());
        break;
    }
  }

  // ==================== BUILD LAPORAN DATA DUMMY ====================

  List<Map<String, dynamic>> _buildLaporanPeminjaman() {
    final List<Map<String, dynamic>> data = [];

    data.add({
      'type': 'header',
      'title': 'LAPORAN PEMINJAMAN ALAT',
      'subtitle': 'Jurusan Permesinan',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    // Summary stats
    data.add({
      'type': 'summary_grid',
      'items': [
        {
          'label': 'Total Peminjaman',
          'value': '${DummyData.peminjamanList.length}',
        },
        {
          'label': 'Menunggu',
          'value':
              '${DummyData.peminjamanList.where((p) => p.status == 'menunggu').length}',
        },
        {
          'label': 'Disetujui',
          'value':
              '${DummyData.peminjamanList.where((p) => p.status == 'disetujui').length}',
        },
        {
          'label': 'Selesai',
          'value':
              '${DummyData.peminjamanList.where((p) => p.status == 'selesai').length}',
        },
      ],
    });

    data.add({'type': 'section_title', 'title': 'Detail Transaksi'});

    for (var p in DummyData.peminjamanList) {
      data.add({
        'type': 'transaction',
        'id': p.id.substring(0, 8),
        'tanggal': DateFormat('dd/MM/yyyy HH:mm').format(p.createdAt),
        'peminjam': p.peminjam?.displayNameOrEmail ?? '-',
        'role': p.peminjam?.role ?? '-',
        'jumlah_alat': '${p.totalItems}',
        'status': p.statusDisplay,
        'status_color': p.status,
        'petugas': p.petugas?.displayNameOrEmail ?? '-',
        'total_denda': p.totalDenda != null && p.totalDenda! > 0
            ? 'Rp ${NumberFormat('#,###').format(p.totalDenda)}'
            : '-',
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanPengembalian() {
    final List<Map<String, dynamic>> data = [];

    final completed = DummyData.peminjamanList
        .where((p) => p.status == 'selesai' || p.status == 'sebagian')
        .toList();

    data.add({
      'type': 'header',
      'title': 'LAPORAN PENGEMBALIAN ALAT',
      'subtitle': 'Jurusan Permesinan',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    final tepatWaktu = completed.where((p) => (p.totalDenda ?? 0) == 0).length;
    final terlambat = completed.where((p) => (p.totalDenda ?? 0) > 0).length;

    data.add({
      'type': 'summary_grid',
      'items': [
        {'label': 'Total Pengembalian', 'value': '${completed.length}'},
        {'label': 'Tepat Waktu', 'value': '$tepatWaktu', 'color': 'success'},
        {'label': 'Terlambat', 'value': '$terlambat', 'color': 'danger'},
        {'label': 'Rata-rata Keterlambatan', 'value': '2.5 hari'},
      ],
    });

    data.add({'type': 'section_title', 'title': 'Detail Pengembalian'});

    for (var p in completed) {
      for (var item in p.items.where((i) => i.status == 'dikembalikan')) {
        data.add({
          'type': 'return_item',
          'kode_alat': item.alat?.kode ?? '-',
          'nama_alat': item.alat?.nama ?? '-',
          'kategori': item.alat?.namaKategori ?? '-',
          'peminjam': p.peminjam?.displayNameOrEmail ?? '-',
          'tanggal_pinjam': DateFormat('dd/MM/yyyy').format(p.createdAt),
          'jatuh_tempo': DateFormat('dd/MM/yyyy').format(item.jatuhTempo),
          'tanggal_kembali': item.dikembalikanPada != null
              ? DateFormat('dd/MM/yyyy').format(item.dikembalikanPada!)
              : '-',
          'terlambat': '${item.terlambatHari ?? 0} hari',
          'denda': 'Rp ${NumberFormat('#,###').format(item.totalDenda ?? 0)}',
        });
      }
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanDenda() {
    final List<Map<String, dynamic>> data = [];

    final withDenda = DummyData.peminjamanList
        .where((p) => (p.totalDenda ?? 0) > 0)
        .toList();

    final totalDenda = withDenda.fold<int>(
      0,
      (sum, p) => sum + (p.totalDenda ?? 0),
    );

    data.add({
      'type': 'header',
      'title': 'LAPORAN DENDA PEMINJAMAN',
      'subtitle': 'Jurusan Permesinan',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    data.add({
      'type': 'summary_highlight',
      'title': 'Total Denda Terkumpul',
      'value': 'Rp ${NumberFormat('#,###').format(totalDenda)}',
      'subtitle': 'Dari ${withDenda.length} transaksi',
    });

    data.add({
      'type': 'summary_grid',
      'items': [
        {'label': 'Transaksi Berdenda', 'value': '${withDenda.length}'},
        {
          'label': 'Rata-rata Denda',
          'value':
              'Rp ${NumberFormat('#,###').format(withDenda.isEmpty ? 0 : totalDenda ~/ withDenda.length)}',
        },
        {'label': 'Denda Tertinggi', 'value': 'Rp 25.000'},
        {'label': 'Denda Terendah', 'value': 'Rp 5.000'},
      ],
    });

    data.add({'type': 'section_title', 'title': 'Detail Denda per Transaksi'});

    for (var p in withDenda) {
      data.add({
        'type': 'denda_item',
        'id': p.id.substring(0, 8),
        'peminjam': p.peminjam?.displayNameOrEmail ?? '-',
        'tanggal': DateFormat('dd/MM/yyyy').format(p.createdAt),
        'total_denda': 'Rp ${NumberFormat('#,###').format(p.totalDenda)}',
        'status': p.statusDisplay,
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanAlat() {
    final List<Map<String, dynamic>> data = [];

    final tersedia = DummyData.alatList
        .where((a) => a.status == 'tersedia')
        .length;
    final dipinjam = DummyData.alatList
        .where((a) => a.status == 'dipinjam')
        .length;
    final nonaktif = DummyData.alatList
        .where((a) => a.status == 'nonaktif')
        .length;
    final rusak = DummyData.alatList.where((a) => a.kondisi == 'rusak').length;
    final hilang = DummyData.alatList
        .where((a) => a.kondisi == 'hilang')
        .length;

    data.add({
      'type': 'header',
      'title': 'LAPORAN INVENTARIS ALAT',
      'subtitle': 'Jurusan Permesinan',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    data.add({
      'type': 'summary_grid',
      'items': [
        {'label': 'Total Alat', 'value': '${DummyData.alatList.length}'},
        {'label': 'Tersedia', 'value': '$tersedia', 'color': 'success'},
        {'label': 'Dipinjam', 'value': '$dipinjam', 'color': 'info'},
        {'label': 'Nonaktif', 'value': '$nonaktif', 'color': 'danger'},
      ],
    });

    // Group by kategori
    final kategoriMap = <String, List<Alat>>{};
    for (var alat in DummyData.alatList) {
      final kat = alat.namaKategori ?? 'Lainnya';
      kategoriMap.putIfAbsent(kat, () => []).add(alat);
    }

    for (var entry in kategoriMap.entries) {
      data.add({
        'type': 'section_title',
        'title': '${entry.key} (${entry.value.length} unit)',
      });

      for (var alat in entry.value) {
        data.add({
          'type': 'alat_item',
          'kode': alat.kode,
          'nama': alat.nama,
          'sub_kategori': alat.namaSubKategori ?? '-',
          'lokasi': alat.lokasiSimpan ?? '-',
          'status': alat.status.toUpperCase(),
          'status_color': alat.status,
          'kondisi': alat.kondisi.toUpperCase(),
          'kondisi_color': alat.kondisi == 'baik'
              ? 'success'
              : (alat.kondisi == 'rusak' ? 'warning' : 'danger'),
        });
      }
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanUser() {
    final List<Map<String, dynamic>> data = [];

    data.add({
      'type': 'header',
      'title': 'LAPORAN AKTIVITAS USER',
      'subtitle': 'Jurusan Permesinan',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    // Stats per role
    final peminjamList = DummyData.users
        .where((u) => u.role == 'peminjam')
        .toList();
    final petugasList = DummyData.users
        .where((u) => u.role == 'petugas')
        .toList();

    data.add({
      'type': 'summary_grid',
      'items': [
        {'label': 'Total User', 'value': '${DummyData.users.length}'},
        {'label': 'Peminjam', 'value': '${peminjamList.length}'},
        {'label': 'Petugas', 'value': '${petugasList.length}'},
        {'label': 'Admin', 'value': '1'},
      ],
    });

    data.add({'type': 'section_title', 'title': 'Aktivitas Peminjam'});

    for (var user in peminjamList) {
      final userPeminjaman = DummyData.peminjamanList
          .where((p) => p.peminjamId == user.id)
          .toList();
      final totalPinjam = userPeminjaman.length;
      final aktif = userPeminjaman
          .where((p) => p.status == 'disetujui' || p.status == 'sebagian')
          .length;
      final selesai = userPeminjaman.where((p) => p.status == 'selesai').length;

      data.add({
        'type': 'user_activity',
        'nama': user.displayNameOrEmail,
        'email': user.email,
        'total_peminjaman': '$totalPinjam',
        'sedang_aktif': '$aktif',
        'sudah_selesai': '$selesai',
        'bergabung': DateFormat('dd/MM/yyyy').format(user.createdAt),
      });
    }

    data.add({'type': 'section_title', 'title': 'Aktivitas Petugas'});

    for (var user in petugasList) {
      final approved = DummyData.peminjamanList
          .where((p) => p.disetujuiOleh == user.id)
          .length;

      data.add({
        'type': 'user_activity',
        'nama': user.displayNameOrEmail,
        'email': user.email,
        'peminjaman_disetujui': '$approved',
        'role': 'Petugas',
        'bergabung': DateFormat('dd/MM/yyyy').format(user.createdAt),
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanAudit() {
    final List<Map<String, dynamic>> data = [];

    data.add({
      'type': 'header',
      'title': 'LAPORAN AUDIT SISTEM',
      'subtitle': 'Log Aktivitas Kritis',
      'periode': 'Januari 2026',
      'dicetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
      'dicetak_oleh': 'Admin',
    });

    // Dummy audit log
    final auditLogs = [
      {
        'waktu': DateTime.now().subtract(Duration(hours: 2)),
        'user': 'admin@mesin.ac.id',
        'aksi': 'Login',
        'target': 'Sistem',
      },
      {
        'waktu': DateTime.now().subtract(Duration(hours: 3)),
        'user': 'petugas1@mesin.ac.id',
        'aksi': 'Approve Peminjaman',
        'target': 'TRX-001',
      },
      {
        'waktu': DateTime.now().subtract(Duration(hours: 5)),
        'user': 'admin@mesin.ac.id',
        'aksi': 'Delete Alat',
        'target': 'GR-SFC-004',
      },
      {
        'waktu': DateTime.now().subtract(Duration(hours: 8)),
        'user': 'mahasiswa1@student.ac.id',
        'aksi': 'Create Peminjaman',
        'target': 'TRX-005',
      },
      {
        'waktu': DateTime.now().subtract(Duration(days: 1)),
        'user': 'admin@mesin.ac.id',
        'aksi': 'Update User',
        'target': 'petugas2@mesin.ac.id',
      },
    ];

    data.add({'type': 'section_title', 'title': 'Log Aktivitas Terbaru'});

    for (var log in auditLogs) {
      data.add({
        'type': 'audit_log',
        'waktu': DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(log['waktu'] as DateTime),
        'user': log['user'],
        'aksi': log['aksi'],
        'target': log['target'],
      });
    }

    return data;
  }

  // ==================== PREVIEW & CETAK ====================

  void _showLaporanPreview(String title, List<Map<String, dynamic>> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminLaporanPreviewPage(
          title: title,
          data: data,
          onCetak: () {
            // Simulasi cetak
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(
                  Icons.check_circle,
                  color: AppColors.success500,
                  size: 64,
                ),
                title: Text('Laporan Berhasil Dicetak'),
                content: Text('Laporan $title telah dicetak/diekspor (dummy).'),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
          onExportPDF: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mengekspor PDF... (dummy)')),
            );
          },
          onExportExcel: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mengekspor Excel... (dummy)')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan & Statistik',
            style: isMobile ? AppTypography.h3 : AppTypography.h2,
          ),
          const SizedBox(height: 4),
          Text(
            'Generate laporan lengkap dari data sistem',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 24),

          // Grid Laporan Options
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 2,
            childAspectRatio: isMobile ? 2.5 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: _laporanOptions
                .map(
                  (opt) => _LaporanOptionCard(
                    title: opt['title'],
                    icon: opt['icon'],
                    color: opt['color'],
                    description: opt['desc'],
                    onTap: () => _generateLaporan(opt['id']),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          AppCard(
            color: AppColors.primary50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Sistem', style: AppTypography.h4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickStat(
                        label: 'Total Peminjaman',
                        value: '${DummyData.peminjamanList.length}',
                        icon: Icons.assignment,
                      ),
                    ),
                    Expanded(
                      child: _QuickStat(
                        label: 'Total Alat',
                        value: '${DummyData.alatList.length}',
                        icon: Icons.build,
                      ),
                    ),
                    Expanded(
                      child: _QuickStat(
                        label: 'Total User',
                        value: '${DummyData.users.length}',
                        icon: Icons.people,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== WIDGET LAPORAN ====================

class _LaporanOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _LaporanOptionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: color.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 20),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary600, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.h3.copyWith(color: AppColors.primary600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ==================== PREVIEW PAGE ====================

class _AdminLaporanPreviewPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final VoidCallback onCetak;
  final VoidCallback onExportPDF;
  final VoidCallback onExportExcel;

  const _AdminLaporanPreviewPage({
    required this.title,
    required this.data,
    required this.onCetak,
    required this.onExportPDF,
    required this.onExportExcel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: $title'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export PDF'),
                  ],
                ),
                onTap: onExportPDF,
              ),
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Export Excel'),
                  ],
                ),
                onTap: onExportExcel,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((item) => _buildItem(item)).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExportPDF,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExportExcel,
                  icon: Icon(Icons.table_chart),
                  label: Text('Excel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 0,
                child: ElevatedButton.icon(
                  onPressed: onCetak,
                  icon: Icon(Icons.print),
                  label: Text('Cetak'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'header':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary700, AppColors.primary600],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
              if (item['subtitle'] != null)
                Text(
                  item['subtitle'],
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Periode: ${item['periode']}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Icon(Icons.print, size: 14, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'Dicetak: ${item['dicetak']}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

      case 'summary_highlight':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.success50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success200),
          ),
          child: Column(
            children: [
              Text(
                item['title'],
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.success700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['value'],
                style: AppTypography.h1.copyWith(color: AppColors.success600),
              ),
              Text(
                item['subtitle'],
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.success700,
                ),
              ),
            ],
          ),
        );

      case 'summary_grid':
        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          children: (item['items'] as List)
              .map<Widget>(
                (i) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: i['color'] == 'success'
                        ? AppColors.success50
                        : i['color'] == 'danger'
                        ? AppColors.danger50
                        : i['color'] == 'warning'
                        ? AppColors.warning50
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        i['value'],
                        style: AppTypography.h4.copyWith(
                          color: i['color'] == 'success'
                              ? AppColors.success600
                              : i['color'] == 'danger'
                              ? AppColors.danger600
                              : i['color'] == 'warning'
                              ? AppColors.warning600
                              : AppColors.neutral900,
                        ),
                      ),
                      Text(
                        i['label'],
                        style: AppTypography.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );

      case 'section_title':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            item['title'],
            style: AppTypography.h4.copyWith(color: AppColors.primary700),
          ),
        );

      case 'transaction':
      case 'return_item':
      case 'denda_item':
      case 'alat_item':
      case 'user_activity':
      case 'audit_log':
        return AppCard(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.entries
                .where(
                  (e) =>
                      e.key != 'type' &&
                      e.key != 'status_color' &&
                      e.key != 'kondisi_color',
                )
                .map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${e.key.replaceAll('_', ' ').toUpperCase()}:',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: e.key == 'status' || e.key == 'kondisi'
                              ? StatusBadge(
                                  status: e.value.toString().toLowerCase(),
                                )
                              : Text(
                                  '${e.value}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }
}

class _RankingCard extends StatelessWidget {
  final String title;
  final List<_RankingItem> items;

  const _RankingCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 16),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: item.rank == 1
                              ? AppColors.secondary500
                              : AppColors.neutral200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${item.rank}',
                            style: TextStyle(
                              color: item.rank == 1
                                  ? Colors.white
                                  : AppColors.neutral700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item.name, style: AppTypography.bodyMedium),
                      ),
                      Text(
                        '${item.count}x',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _RankingItem {
  final int rank;
  final String name;
  final int count;

  _RankingItem({required this.rank, required this.name, required this.count});
}
