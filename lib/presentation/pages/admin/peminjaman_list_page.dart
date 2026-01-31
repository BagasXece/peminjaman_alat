// lib/presentation/pages/admin/peminjaman_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../blocs/peminjaman/peminjaman_admin_cubit.dart';
import 'peminjaman_detail_page.dart';

class PeminjamanListPage extends StatelessWidget {
  final bool isEmbedded;
  
  const PeminjamanListPage({
    Key? key,
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika embedded, langsung return content tanpa Scaffold
    if (isEmbedded) {
      return const _PeminjamanListContent();
    }
    
    // Jika standalone, gunakan BlocProvider + Scaffold
    return BlocProvider(
      create: (context) => context.read<PeminjamanAdminCubit>(), // Ambil dari parent atau create new
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manajemen Peminjaman'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => context.read<PeminjamanAdminCubit>().loadPeminjaman(),
            ),
          ],
        ),
        body: const _PeminjamanListContent(),
      ),
    );
  }
}

class _PeminjamanListContent extends StatefulWidget {
  const _PeminjamanListContent();

  @override
  State<_PeminjamanListContent> createState() => _PeminjamanListContentState();
}

class _PeminjamanListContentState extends State<_PeminjamanListContent> {
  String? _filterStatus;

  final List<Map<String, dynamic>> _statusFilters = [
    {'id': null, 'label': 'Semua', 'color': AppColors.neutral600},
    {'id': 'menunggu', 'label': 'Menunggu', 'color': AppColors.warning600},
    {'id': 'disetujui', 'label': 'Disetujui', 'color': AppColors.success600},
    {'id': 'sebagian', 'label': 'Sebagian', 'color': AppColors.info600},
    {'id': 'selesai', 'label': 'Selesai', 'color': AppColors.primary600},
    {'id': 'ditolak', 'label': 'Ditolak', 'color': AppColors.danger600},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<PeminjamanAdminCubit, PeminjamanAdminState>(
      listener: (context, state) {
        if (state is PeminjamanAdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success600),
          );
        } else if (state is PeminjamanAdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger600),
          );
        }
      },
      child: BlocBuilder<PeminjamanAdminCubit, PeminjamanAdminState>(
        builder: (context, state) {
          if (state is PeminjamanAdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PeminjamanAdminListLoaded) {
            return Column(
              children: [
                // Filter Chips
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _statusFilters[index];
                      final isSelected = _filterStatus == filter['id'];
                      return FilterChip(
                        selected: isSelected,
                        label: Text(filter['label']),
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? filter['id'] : null;
                          });
                          context.read<PeminjamanAdminCubit>().loadPeminjaman(status: _filterStatus);
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
                
                // List
                Expanded(
                  child: state.list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.neutral300),
                              SizedBox(height: 16),
                              Text('Tidak ada peminjaman', style: AppTypography.h4.copyWith(color: AppColors.neutral500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: state.list.length,
                          itemBuilder: (context, index) {
                            final item = state.list[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Text(
                                  item.peminjam?.displayNameOrEmail ?? '-',
                                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      '${item.kodePeminjaman ?? '-'} • ${DateFormat('dd/MM/yyyy').format(item.createdAt)}',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
                                    ),
                                    SizedBox(height: 4),
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
                                  padding: EdgeInsets.symmetric(horizontal: 8),
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
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return Center(child: Text('Tidak ada data'));
        },
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