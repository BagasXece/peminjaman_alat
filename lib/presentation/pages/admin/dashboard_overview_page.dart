// lib/presentation/pages/admin/dashboard_overview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:peminjaman_alat/presentation/widgets/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../presentation/blocs/dashboard/dashboard_cubit.dart';

class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({Key? key}) : super(key: key);

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  Future<void> _refresh() async {
    await context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger600,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _refresh,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions (Mobile: full width buttons)
                if (isMobile) ...[
                  _buildQuickActionsMobile(),
                  const SizedBox(height: 24),
                ],

                // Stats Grid
                if (state is DashboardLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is DashboardLoaded) ...[
                  _buildStatsGrid(state.stats, isMobile),
                  const SizedBox(height: 24),
                  
                  // Charts & Lists Row (Desktop: side by side, Mobile: stacked)
                  if (isMobile) ...[
                    _buildStatusChart(state.stats),
                    const SizedBox(height: 24),
                    _buildRecentActivities(state.stats.recentActivities),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildStatusChart(state.stats),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: _buildRecentActivities(state.stats.recentActivities),
                        ),
                      ],
                    ),
                ] else if (state is DashboardError)
                  _buildErrorState(state.message),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsMobile() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to index 3 (Alat)
            // This requires callback or navigation logic
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Alat Baru'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to index 4 (Peminjaman)
          },
          icon: const Icon(Icons.assignment),
          label: const Text('Lihat Peminjaman'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats, bool isMobile) {
    final statsItems = [
      _StatItem(
        label: 'Total Alat',
        value: stats.totalAlat.toString(),
        icon: Icons.inventory_2,
        color: AppColors.primary600,
        subtitle: '${stats.alatTersedia} tersedia',
      ),
      _StatItem(
        label: 'Peminjaman Aktif',
        value: (stats.peminjamanDisetujui + stats.peminjamanMenunggu).toString(),
        icon: Icons.swap_horiz,
        color: AppColors.warning600,
        subtitle: '${stats.peminjamanMenunggu} menunggu',
      ),
      _StatItem(
        label: 'Total Users',
        value: stats.totalUsers.toString(),
        icon: Icons.people,
        color: AppColors.info600,
        subtitle: '${stats.totalPetugas} petugas',
      ),
      _StatItem(
        label: 'Selesai',
        value: stats.peminjamanSelesai.toString(),
        icon: Icons.check_circle,
        color: AppColors.success600,
        subtitle: 'Peminjaman',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.4,
      ),
      itemCount: statsItems.length,
      itemBuilder: (context, index) {
        final item = statsItems[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChart(DashboardStats stats) {
    final total = stats.totalAlat > 0 ? stats.totalAlat : 1;
    final tersediaPercent = stats.alatTersedia / total;
    final dipinjamPercent = stats.alatDipinjam / total;
    final tidakTersediaPercent = stats.alatTidakTersedia / total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Bar Chart
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: (tersediaPercent * 100).toInt(),
                  child: Container(
                    height: 24,
                    color: AppColors.success600,
                  ),
                ),
                Expanded(
                  flex: (dipinjamPercent * 100).toInt(),
                  child: Container(
                    height: 24,
                    color: AppColors.warning600,
                  ),
                ),
                Expanded(
                  flex: (tidakTersediaPercent * 100).toInt(),
                  child: Container(
                    height: 24,
                    color: AppColors.danger600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          _buildLegendItem('Tersedia', stats.alatTersedia, AppColors.success600),
          _buildLegendItem('Dipinjam', stats.alatDipinjam, AppColors.warning600),
          _buildLegendItem('Tidak Tersedia', stats.alatTidakTersedia, AppColors.danger600),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Text(
            value.toString(),
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<RecentActivity> activities) {
    return AppCard(
      child: activities.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Tidak ada aktivitas terbaru',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
                ),
              ),
            )
          : Column(
              children: activities.map((activity) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(activity.type),
                    color: _getActivityColor(activity.type),
                    size: 20,
                  ),
                ),
                title: Text(
                  activity.title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${activity.subtitle} • ${DateFormat('dd/MM HH:mm').format(activity.timestamp)}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(activity.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    activity.status.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: _getStatusColor(activity.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )).toList(),
            ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
            const SizedBox(height: 16),
            Text('Terjadi Kesalahan', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'peminjaman':
        return AppColors.info600;
      case 'pengembalian':
        return AppColors.success600;
      case 'user_baru':
        return AppColors.primary600;
      default:
        return AppColors.neutral600;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'peminjaman':
        return Icons.arrow_outward;
      case 'pengembalian':
        return Icons.arrow_back;
      case 'user_baru':
        return Icons.person_add;
      default:
        return Icons.circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return AppColors.warning600;
      case 'disetujui':
        return AppColors.success600;
      case 'selesai':
        return AppColors.primary600;
      case 'ditolak':
        return AppColors.danger600;
      default:
        return AppColors.neutral600;
    }
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}