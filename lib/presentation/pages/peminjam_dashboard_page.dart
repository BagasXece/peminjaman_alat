// lib/presentation/pages/peminjam_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
// import '../../core/constants/app_constants.dart';
import '../../domain/entities/peminjaman.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/peminjaman/peminjaman_cubit.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'peminjaman/form_peminjaman_page.dart';
import 'peminjaman/detail_peminjaman_page.dart';

class PeminjamDashboardPage extends StatefulWidget {
  const PeminjamDashboardPage({Key? key}) : super(key: key);

  @override
  State<PeminjamDashboardPage> createState() => _PeminjamDashboardPageState();
}

class _PeminjamDashboardPageState extends State<PeminjamDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<PeminjamanCubit>().loadPeminjaman(
            peminjamId: authState.user.id,
          );
    }
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
          // App Bar dengan tombol keluar
          SliverAppBar(
            expandedHeight: 180,
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
                      AppColors.primary700,
                      AppColors.primary600,
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
                                    'Selamat Datang,',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.displayNameOrEmail,
                                    style: AppTypography.h3.copyWith(
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Tombol Keluar di AppBar
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              offset: Offset(0, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 20),
                                      SizedBox(width: 12),
                                      Text('Profil'),
                                    ],
                                  ),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: AppColors.danger600,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Keluar',
                                        style: TextStyle(
                                          color: AppColors.danger600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'logout') {
                                  _confirmLogout();
                                }
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Role: ${user.role.toUpperCase()}',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Action
                  AppCard(
                    color: AppColors.secondary50,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: AppColors.secondary700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pinjam Alat Baru',
                                style: AppTypography.h4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ajukan peminjaman alat permesinan',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.secondary600,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FormPeminjamanPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Peminjaman',
                        style: AppTypography.h4,
                      ),
                      TextButton.icon(
                        onPressed: _loadData,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List Peminjaman
                  BlocBuilder<PeminjamanCubit, PeminjamanState>(
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
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.danger500,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: AppTypography.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is PeminjamanLoaded) {
                        if (state.peminjaman.isEmpty) {
                          return EmptyState(
                            title: 'Belum Ada Peminjaman',
                            subtitle: 'Anda belum pernah meminjam alat. \nAjukan peminjaman pertama Anda!',
                            icon: Icons.inventory_2_outlined,
                            action: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FormPeminjamanPage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add),
                              label: Text('Pinjam Alat'),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.peminjaman.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final peminjaman = state.peminjaman[index];
                            return _PeminjamanCard(
                              peminjaman: peminjaman,
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

                  // Bottom padding agar tidak terlalu mepet
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeminjamanCard extends StatelessWidget {
  final Peminjaman peminjaman;
  final VoidCallback onTap;

  const _PeminjamanCard({
    Key? key,
    required this.peminjaman,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${peminjaman.id.substring(0, 8)}...',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(peminjaman.createdAt),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neutral700,
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
                size: 20,
                color: AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                '${peminjaman.totalItems} Alat',
                style: AppTypography.bodyMedium,
              ),
              const Spacer(),
              if (peminjaman.totalDenda != null && peminjaman.totalDenda! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Denda: Rp ${NumberFormat('#,###').format(peminjaman.totalDenda)}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.danger700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (peminjaman.status == 'menunggu') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.warning600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menunggu persetujuan petugas',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}