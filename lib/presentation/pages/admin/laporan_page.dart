// lib/presentation/pages/admin/laporan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../blocs/laporan/laporan_cubit.dart';
import '../../widgets/app_card.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _selectedTab = 0;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<_LaporanTab> _tabs = [
    _LaporanTab(icon: Icons.assignment, label: 'Peminjaman'),
    _LaporanTab(icon: Icons.money_off, label: 'Denda'),
    _LaporanTab(icon: Icons.inventory, label: 'Inventaris'),
    _LaporanTab(icon: Icons.people, label: 'User'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentTabData();
  }

  void _loadCurrentTabData() {
    switch (_selectedTab) {
      case 0:
        context.read<LaporanCubit>().loadLaporanPeminjaman();
        break;
      case 1:
        context.read<LaporanCubit>().loadLaporanDenda();
        break;
      case 2:
        context.read<LaporanCubit>().loadLaporanInventaris();
        break;
      case 3:
        context.read<LaporanCubit>().loadLaporanUser();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    return BlocConsumer<LaporanCubit, LaporanState>(
      listener: (context, state) {
        if (state is LaporanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger600,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _loadCurrentTabData,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _loadCurrentTabData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab Bar (Horizontal Scroll untuk Mobile)
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = _selectedTab == index;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedTab = index);
                            _loadCurrentTabData();
                          }
                        },
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.icon,
                              size: 18,
                              color: isSelected ? AppColors.primary700 : AppColors.neutral600,
                            ),
                            const SizedBox(width: 8),
                            Text(tab.label),
                          ],
                        ),
                        selectedColor: AppColors.primary100,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary700 : AppColors.neutral600,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary600 : AppColors.neutral300,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Content Area
                if (state is LaporanLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  _buildCurrentTabContent(state, isMobile),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentTabContent(LaporanState state, bool isMobile) {
    switch (_selectedTab) {
      case 0:
        return _buildPeminjamanContent(state);
      case 1:
        return _buildDendaContent(state, isMobile);
      case 2:
        return _buildInventarisContent(state, isMobile);
      case 3:
        return _buildUserContent(state, isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPeminjamanContent(LaporanState state) {
    if (state is LaporanPeminjamanLoaded) {
      if (state.data.isEmpty) {
        return _buildEmptyState('Tidak ada data peminjaman');
      }
      return Column(
        children: state.data.map((item) => AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.kodePeminjaman ?? '-',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(item.statusPeminjaman),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Peminjam: ${item.namaPeminjam ?? '-'}',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  'Tanggal: ${item.tanggalPengajuan != null ? DateFormat('dd/MM/yyyy').format(item.tanggalPengajuan!) : '-'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                Text(
                  'Total Item: ${item.totalItem}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                if (item.totalDenda > 0)
                  Text(
                    'Denda: ${currencyFormat.format(item.totalDenda)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.danger600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        )).toList(),
      );
    }
    return _buildErrorStateWidget();
  }

  Widget _buildDendaContent(LaporanState state, bool isMobile) {
    if (state is LaporanDendaLoaded) {
      if (state.data.isEmpty) {
        return _buildEmptyState('Tidak ada data denda');
      }

      final totalDenda = state.data.fold<int>(0, (sum, item) => sum + item.totalDenda);

      return Column(
        children: [
          // Summary Card
          AppCard(
            color: AppColors.primary50,
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Denda',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalDenda),
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: AppColors.primary200,
                ),
              ],
            ),
          ),
          // List
          ...state.data.map((item) => AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.namaPeminjam ?? '-',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Item Terlambat: ${item.totalItemTerlambat}',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    'Total: ${currencyFormat.format(item.totalDenda)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.danger600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  item.statusPelunasan == 'lunas' ? 'LUNAS' : 'BELUM LUNAS',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: item.statusPelunasan == 'lunas' 
                    ? AppColors.success600 
                    : AppColors.warning600,
              ),
            ),
          )).toList(),
        ],
      );
    }
    return _buildErrorStateWidget();
  }

  Widget _buildInventarisContent(LaporanState state, bool isMobile) {
    if (state is LaporanInventarisLoaded) {
      if (state.data.isEmpty) {
        return _buildEmptyState('Tidak ada data inventaris');
      }

      final totalStok = state.data.fold<int>(0, (sum, item) => sum + item.stokTotal);
      final totalTersedia = state.data.fold<int>(0, (sum, item) => sum + item.stokTersedia);
      final totalDipinjam = state.data.fold<int>(0, (sum, item) => sum + item.stokDipinjam);

      return Column(
        children: [
          // Summary Stats
          Row(
            children: [
              _buildStatCard('Total Unit', totalStok, AppColors.primary600),
              const SizedBox(width: 8),
              _buildStatCard('Tersedia', totalTersedia, AppColors.success600),
              const SizedBox(width: 8),
              _buildStatCard('Dipinjam', totalDipinjam, AppColors.warning600),
            ],
          ),
          const SizedBox(height: 16),
          // List
          ...state.data.map((item) => AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.namaKategori} › ${item.namaSubKategori}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInventoryStat(
                      'Total',
                      item.stokTotal,
                      AppColors.neutral600,
                    ),
                    _buildInventoryStat(
                      'Tersedia',
                      item.stokTersedia,
                      AppColors.success600,
                    ),
                    _buildInventoryStat(
                      'Dipinjam',
                      item.stokDipinjam,
                      AppColors.warning600,
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      );
    }
    return _buildErrorStateWidget();
  }

  Widget _buildUserContent(LaporanState state, bool isMobile) {
    if (state is LaporanUserLoaded) {
      if (state.data.isEmpty) {
        return _buildEmptyState('Tidak ada data user');
      }

      final totalUsers = state.data.length;
      final totalPeminjaman = state.data.fold<int>(0, (sum, item) => sum + item.totalPeminjaman);

      return Column(
        children: [
          // Summary
          AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserStat('Total User', totalUsers),
                _buildUserStat('Total Peminjaman', totalPeminjaman),
              ],
            ),
          ),
          // List
          ...state.data.map((item) => AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(item.role).withOpacity(0.1),
                child: Text(
                  item.displayName?.isNotEmpty == true 
                      ? item.displayName![0].toUpperCase() 
                      : '?',
                  style: TextStyle(color: _getRoleColor(item.role)),
                ),
              ),
              title: Text(
                item.displayName ?? item.email,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.email,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniStat('Total', item.totalPeminjaman),
                      _buildMiniStat('Aktif', item.peminjamanAktif),
                      _buildMiniStat('Selesai', item.peminjamanSelesai),
                    ],
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  item.role.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: _getRoleColor(item.role),
              ),
            ),
          )).toList(),
        ],
      );
    }
    return _buildErrorStateWidget();
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: AppCard(
        color: color.withOpacity(0.05),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: AppTypography.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: AppTypography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary600,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          Text(
            value.toString(),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'menunggu':
        color = AppColors.warning600;
        break;
      case 'disetujui':
      case 'selesai':
        color = AppColors.success600;
        break;
      case 'ditolak':
      case 'dibatalkan':
        color = AppColors.danger600;
        break;
      default:
        color = AppColors.neutral600;
    }
    
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.danger600;
      case 'petugas':
        return AppColors.secondary600;
      default:
        return AppColors.info600;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.insert_drive_file_outlined, size: 64, color: AppColors.neutral300),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.h4.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStateWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentTabData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaporanTab {
  final IconData icon;
  final String label;
  
  _LaporanTab({required this.icon, required this.label});
}