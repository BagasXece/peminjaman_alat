// lib/presentation/pages/admin/alat_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/alat.dart';
import '../../blocs/alat/alat_cubit.dart';
import '../../widgets/alat_form_dialog.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class AlatManagementPage extends StatefulWidget {
  final bool isEmbedded;
  
  const AlatManagementPage({
    Key? key, 
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  State<AlatManagementPage> createState() => _AlatManagementPageState();
}

class _AlatManagementPageState extends State<AlatManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    if (!widget.isEmbedded) {
      context.read<AlatCubit>().loadAlat();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<AlatCubit>().refreshAlat();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;

    Widget content = BlocConsumer<AlatCubit, AlatState>(
      listener: (context, state) {
        if (state is AlatActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AlatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger600,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _refresh(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Jika embedded, jangan pakai CustomScrollView lagi karena sudah di parent
        if (widget.isEmbedded) {
          return _buildContentBody(context, state, isMobile);
        }
        
        // Jika standalone, pakai Scaffold + CustomScrollView
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text('Manajemen Alat', style: AppTypography.h4),
                  actions: [
                    if (!isMobile)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddDialog(context),
                          icon: Icon(Icons.add),
                          label: Text('Tambah Alat'),
                        ),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _buildContentBody(context, state, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddDialog(context),
                  icon: Icon(Icons.add),
                  label: Text('Tambah'),
                )
              : null,
        );
      },
    );

    return content;
  }

  Widget _buildContentBody(BuildContext context, AlatState state, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search & Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari alat...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<AlatCubit>().loadAlat();
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    context.read<AlatCubit>().loadAlat(search: val);
                  },
                ),
              ),
              SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedStatus,
                hint: Text('Status'),
                items: [
                  DropdownMenuItem(value: null, child: Text('Semua')),
                  DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                  DropdownMenuItem(value: 'tidak_tersedia', child: Text('Tidak Tersedia')),
                ],
                onChanged: (val) {
                  setState(() => _selectedStatus = val);
                  context.read<AlatCubit>().loadAlat(status: val);
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          
          if (state is AlatLoading)
            Center(child: CircularProgressIndicator())
          else if (state is AlatLoaded) ...[
            if (state.alat.isEmpty)
              _buildEmptyState()
            else
              isMobile
                  ? _buildMobileList(state.alat)
                  : _buildDesktopList(state.alat),
          ] else if (state is AlatError)
            _buildErrorState(state.message),
            
          // FAB space untuk embedded mode
          if (widget.isEmbedded && isMobile) SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDesktopList(List<Alat> alat) {
    return AppCard(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Nama Alat', style: AppTypography.labelLarge)),
                Expanded(child: Text('Kategori', style: AppTypography.labelLarge)),
                Expanded(child: Text('Kondisi', style: AppTypography.labelLarge)),
                Expanded(child: Text('Status', style: AppTypography.labelLarge)),
                SizedBox(width: 100, child: Text('Aksi', style: AppTypography.labelLarge)),
              ],
            ),
          ),
          Divider(height: 1),
          // List
          ...alat.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            Text(item.kode, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                      ),
                      Expanded(child: Text(item.namaKategori ?? '-', style: AppTypography.bodyMedium)),
                      Expanded(
                        child: Text(
                          item.kondisi.toUpperCase(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: item.kondisi == 'baik' ? AppColors.success600 : AppColors.danger600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: StatusBadge(status: item.status)),
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20),
                              onPressed: () => _showEditDialog(context, item),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
                              onPressed: () => _confirmDelete(context, item),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key < alat.length - 1) Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Alat> alat) {
    return Column(
      children: alat.map((item) => AppCard(
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(item.kode, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                    ],
                  ),
                ),
                StatusBadge(status: item.status),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: AppColors.neutral500),
                SizedBox(width: 8),
                Text(item.namaKategori ?? '-', style: AppTypography.bodySmall),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.build, size: 16, color: AppColors.neutral500),
                SizedBox(width: 8),
                Text('${item.kondisi} • ${item.lokasiSimpan ?? 'Tidak ada lokasi'}', 
                    style: AppTypography.bodySmall),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, item),
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, item),
                  icon: Icon(Icons.delete, size: 18, color: AppColors.danger600),
                  label: Text('Hapus', style: TextStyle(color: AppColors.danger600)),
                ),
              ],
            ),
          ],
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
            SizedBox(height: 16),
            Text('Tidak ada data alat', style: AppTypography.h4.copyWith(color: AppColors.neutral500)),
            SizedBox(height: 8),
            Text('Tambahkan alat baru untuk memulai', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral400)),
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
            SizedBox(height: 16),
            Text('Terjadi Kesalahan', style: AppTypography.h4),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AlatCubit>(),
        child: AlatFormDialog(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Alat alat) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AlatCubit>(),
        child: AlatFormDialog(alat: alat),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Alat alat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ingin menghapus alat berikut?'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alat.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(alat.kode, style: AppTypography.bodySmall),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Catatan: Alat yang sedang dipinjam tidak dapat dihapus.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning600),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AlatCubit>().removeAlat(alat.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}