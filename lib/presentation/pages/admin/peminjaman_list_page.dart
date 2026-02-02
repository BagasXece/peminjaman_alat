// lib/presentation/pages/admin/peminjaman_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/peminjaman.dart';
import '../../blocs/peminjaman/peminjaman_admin_cubit.dart';
import 'peminjaman_detail_page.dart';

class PeminjamanListPage extends StatefulWidget {
  const PeminjamanListPage({Key? key}) : super(key: key);

  @override
  State<PeminjamanListPage> createState() => _PeminjamanListPageState();
}

class _PeminjamanListPageState extends State<PeminjamanListPage> {
  String? _filterStatus;

  final List<Map<String, dynamic>> _statusFilters = [
    {'id': null, 'label': 'Semua', 'color': AppColors.neutral600},
    {'id': 'menunggu', 'label': 'Menunggu', 'color': AppColors.warning600},
    {'id': 'disetujui', 'label': 'Disetujui', 'color': AppColors.success600},
    {'id': 'sebagian', 'label': 'Sebagian', 'color': AppColors.info600},
    {'id': 'selesai', 'label': 'Selesai', 'color': AppColors.primary600},
    {'id': 'dibatalkan', 'label': 'Dibatalkan', 'color': AppColors.danger500},
    {'id': 'ditolak', 'label': 'Ditolak', 'color': AppColors.danger600},
  ];

  @override
  void initState() {
    super.initState();
    context.read<PeminjamanAdminCubit>().loadPeminjaman();
  }

  Future<void> _refresh() async {
    await context.read<PeminjamanAdminCubit>().loadPeminjaman(status: _filterStatus);
  }

  void _applyFilter(String? status) {
    setState(() => _filterStatus = status);
    context.read<PeminjamanAdminCubit>().loadPeminjaman(status: status);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PeminjamanAdminCubit, PeminjamanAdminState>(
      listener: (context, state) {
        if (state is PeminjamanAdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is PeminjamanAdminError) {
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
                // Filter Chips - Horizontal scroll
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _statusFilters[index];
                      final isSelected = _filterStatus == filter['id'];
                      return FilterChip(
                        selected: isSelected,
                        label: Text(filter['label']),
                        onSelected: (selected) {
                          _applyFilter(selected ? filter['id'] : null);
                        },
                        selectedColor: (filter['color'] as Color).withOpacity(0.1),
                        checkmarkColor: filter['color'] as Color,
                        labelStyle: TextStyle(
                          color: isSelected ? filter['color'] as Color : AppColors.neutral700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? filter['color'] as Color : AppColors.neutral300,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                if (state is PeminjamanAdminLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is PeminjamanAdminListLoaded) ...[
                  if (state.list.isEmpty)
                    _buildEmptyState()
                  else
                    _buildList(state.list),
                ] else if (state is PeminjamanAdminError)
                  _buildErrorState(state.message)
                else
                  const SizedBox.shrink(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<Peminjaman> list) {
    return Column(
      children: list.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neutral200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            item.peminjam?.displayNameOrEmail ?? '-',
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${item.kodePeminjaman ?? '-'} • ${DateFormat('dd/MM/yyyy').format(item.createdAt)}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.items.length} alat dipinjam',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(
              item.status.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(color: Colors.white),
            ),
            backgroundColor: _getStatusColor(item.status),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PeminjamanAdminCubit>(),
                child: PeminjamanDetailPage(id: item.id),
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.neutral300),
            const SizedBox(height: 16),
            Text('Tidak ada peminjaman', style: AppTypography.h4.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 8),
            Text(
              _filterStatus != null 
                ? 'Tidak ada peminjaman dengan status ini' 
                : 'Belum ada data peminjaman',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch(status) {
      case 'menunggu':
        return AppColors.warning600;
      case 'disetujui':
        return AppColors.success600;
      case 'sebagian':
        return AppColors.info600;
      case 'selesai':
        return AppColors.primary600;
      case 'ditolak':
      case 'dibatalkan':
        return AppColors.danger600;
      default:
        return AppColors.neutral600;
    }
  }
}