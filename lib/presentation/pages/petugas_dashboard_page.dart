// lib/presentation/pages/petugas_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
// import '../../core/constants/app_constants.dart';
import '../../domain/entities/peminjaman.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/peminjaman_cubit.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'detail_peminjaman_page.dart';
import 'form_pengembalian_page.dart';

class PetugasDashboardPage extends StatefulWidget {
  const PetugasDashboardPage({Key? key}) : super(key: key);

  @override
  State<PetugasDashboardPage> createState() => _PetugasDashboardPageState();
}

class _PetugasDashboardPageState extends State<PetugasDashboardPage> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Semua', 'color': AppColors.neutral600},
    {'id': 'menunggu', 'label': 'Menunggu', 'color': AppColors.warning600},
    {'id': 'disetujui', 'label': 'Disetujui', 'color': AppColors.info600},
    {'id': 'sebagian', 'label': 'Sebagian', 'color': AppColors.secondary600},
    {'id': 'selesai', 'label': 'Selesai', 'color': AppColors.success600},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<PeminjamanCubit>().loadPeminjaman(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
        );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Keluar'),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger600,
            ),
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
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary800,
                      AppColors.secondary600,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                    'Dashboard Petugas',
                                    style: AppTypography.h3.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.displayNameOrEmail,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Tombol Keluar di AppBar
                            IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              tooltip: 'Keluar',
                              onPressed: _confirmLogout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter['id'];
                      return FilterChip(
                        selected: isSelected,
                        label: Text(filter['label']),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter['id'];
                          });
                          _loadData();
                        },
                        selectedColor: filter['color'].withOpacity(0.1),
                        checkmarkColor: filter['color'],
                        labelStyle: TextStyle(
                          color: isSelected ? filter['color'] : AppColors.neutral700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? filter['color'] : AppColors.neutral300,
                        ),
                      );
                    },
                  ),
                ),

                // Stats Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<PeminjamanCubit, PeminjamanState>(
                    builder: (context, state) {
                      if (state is PeminjamanLoaded) {
                        final menunggu = state.peminjaman
                            .where((p) => p.status == 'menunggu')
                            .length;
                        final disetujui = state.peminjaman
                            .where((p) => p.status == 'disetujui' || p.status == 'sebagian')
                            .length;

                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Menunggu',
                                value: menunggu.toString(),
                                color: AppColors.warning500,
                                icon: Icons.pending_actions,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Aktif',
                                value: disetujui.toString(),
                                color: AppColors.info500,
                                icon: Icons.play_circle_outline,
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // List Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Peminjaman',
                        style: AppTypography.h4,
                      ),
                      TextButton.icon(
                        onPressed: _loadData,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Refresh'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Peminjaman List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocConsumer<PeminjamanCubit, PeminjamanState>(
                    listener: (context, state) {
                      if (state is PeminjamanUpdated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status peminjaman diperbarui'),
                            backgroundColor: AppColors.success500,
                          ),
                        );
                        _loadData();
                      }
                    },
                    builder: (context, state) {
                      if (state is PeminjamanLoading) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is PeminjamanError) {
                        return EmptyState(
                          title: 'Terjadi Kesalahan',
                          subtitle: state.message,
                          icon: Icons.error_outline,
                          action: ElevatedButton(
                            onPressed: _loadData,
                            child: Text('Coba Lagi'),
                          ),
                        );
                      }

                      if (state is PeminjamanLoaded) {
                        if (state.peminjaman.isEmpty) {
                          return EmptyState(
                            title: 'Tidak Ada Peminjaman',
                            subtitle: 'Tidak ada peminjaman dengan filter ini',
                            icon: Icons.inventory_2_outlined,
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.peminjaman.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final peminjaman = state.peminjaman[index];
                            return _PetugasPeminjamanCard(
                              peminjaman: peminjaman,
                              onApprove: peminjaman.canApprove
                                  ? () => _showApproveDialog(peminjaman)
                                  : null,
                              onReject: peminjaman.canApprove
                                  ? () => _showRejectDialog(peminjaman)
                                  : null,
                              onProcessReturn: peminjaman.canReturn
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => FormPengembalianPage(
                                            peminjamanId: peminjaman.id,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailPeminjamanPage(
                                      peminjamanId: peminjaman.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(Peminjaman peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Setujui Peminjaman?'),
        content: Text(
          'Anda akan menyetujui peminjaman ${peminjaman.peminjam?.displayNameOrEmail} '
          'untuk ${peminjaman.totalItems} alat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final user = (context.read<AuthCubit>().state as Authenticated).user;
              context.read<PeminjamanCubit>().approvePeminjaman(peminjaman.id, user.id);
            },
            child: Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Peminjaman peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tolak Peminjaman?'),
        content: Text(
          'Anda akan menolak peminjaman ini. Alat tidak akan dipinjamkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final user = (context.read<AuthCubit>().state as Authenticated).user;
              context.read<PeminjamanCubit>().rejectPeminjaman(peminjaman.id, user.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger600,
            ),
            child: Text('Tolak'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withOpacity(0.05),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.h2.copyWith(color: color),
              ),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PetugasPeminjamanCard extends StatelessWidget {
  final Peminjaman peminjaman;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onProcessReturn;
  final VoidCallback onTap;

  const _PetugasPeminjamanCard({
    Key? key,
    required this.peminjaman,
    this.onApprove,
    this.onReject,
    this.onProcessReturn,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peminjaman.peminjam?.displayNameOrEmail ?? '-',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(peminjaman.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: peminjaman.status,
                isLarge: true,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 18,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                '${peminjaman.totalItems} Alat',
                style: AppTypography.bodyMedium,
              ),
              if (peminjaman.returnedItems > 0) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.success500,
                ),
                const SizedBox(width: 8),
                Text(
                  '${peminjaman.returnedItems} Kembali',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success700,
                  ),
                ),
              ],
            ],
          ),
          if (onApprove != null || onReject != null || onProcessReturn != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success600,
                      ),
                    ),
                  ),
                if (onReject != null) ...[
                  if (onApprove != null) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger600,
                      ),
                    ),
                  ),
                ],
                if (onProcessReturn != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onProcessReturn,
                      icon: Icon(Icons.assignment_return, size: 18),
                      label: Text('Proses Kembali'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}