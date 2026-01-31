// lib/presentation/pages/petugas_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/alat.dart';
import '../../domain/entities/peminjaman.dart';
import '../blocs/alat/alat_cubit.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/peminjaman/peminjaman_cubit.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'peminjaman/detail_peminjaman_page.dart';
import 'pengembalian/form_pengembalian_page.dart';

class PetugasDashboardPage extends StatefulWidget {
  const PetugasDashboardPage({super.key});

  @override
  State<PetugasDashboardPage> createState() => _PetugasDashboardPageState();
}

class _PetugasDashboardPageState extends State<PetugasDashboardPage> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Semua', 'color': AppColors.neutral600},
    {'id': 'menunggu', 'label': 'Menunggu', 'color': AppColors.warning600},
    {'id': 'disetujui', 'label': 'Disetujui', 'color': AppColors.info600},
    {'id': 'ditolak', 'label': 'Ditolak', 'color': AppColors.danger600},
    {'id': 'sebagian', 'label': 'Sebagian', 'color': AppColors.secondary600},
    {'id': 'selesai', 'label': 'Selesai', 'color': AppColors.success600},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<AlatCubit>().loadAlat(); // Load alat untuk laporan alat
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
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  // ==================== LAPORAN DARI DATA STATE ====================

  void _showLaporanMenu() {
    final peminjamanState = context.read<PeminjamanCubit>().state;
    final alatState = context.read<AlatCubit>().state;
    
    if (peminjamanState is! PeminjamanLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data peminjaman belum dimuat')),
      );
      return;
    }

    final peminjamanList = peminjamanState.peminjaman;
    final List<Alat> alatList = alatState is AlatLoaded ? alatState.alat : [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Cetak Laporan', style: AppTypography.h3),
                const SizedBox(height: 4),
                Text('Pilih jenis laporan dari data sistem', 
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500)),
                const SizedBox(height: 24),

                // Laporan Peminjaman
                _LaporanCard(
                  icon: Icons.assignment,
                  title: 'Laporan Peminjaman',
                  subtitle: '${peminjamanList.length} total transaksi',
                  color: AppColors.info600,
                  onTap: () => _generateLaporanPeminjaman(peminjamanList),
                ),
                const SizedBox(height: 12),

                // Laporan Pengembalian
                _LaporanCard(
                  icon: Icons.assignment_return,
                  title: 'Laporan Pengembalian',
                  subtitle: '${peminjamanList.where((p) => p.status == 'selesai' || p.status == 'sebagian').length} transaksi selesai',
                  color: AppColors.success600,
                  onTap: () => _generateLaporanPengembalian(peminjamanList),
                ),
                const SizedBox(height: 12),

                // Laporan Denda
                _LaporanCard(
                  icon: Icons.money_off,
                  title: 'Laporan Denda',
                  subtitle: 'Rp ${NumberFormat('#,###').format(_calculateTotalDenda(peminjamanList))} total denda',
                  color: AppColors.danger600,
                  onTap: () => _generateLaporanDenda(peminjamanList),
                ),
                const SizedBox(height: 12),

                // Laporan Alat
                _LaporanCard(
                  icon: Icons.build,
                  title: 'Laporan Status Alat',
                  subtitle: alatList.isNotEmpty 
                      ? '${alatList.where((a) => a.status == 'tersedia').length} tersedia, '
                        '${alatList.where((a) => a.status == 'dipinjam').length} dipinjam'
                      : 'Data alat belum tersedia',
                  color: AppColors.secondary600,
                  onTap: alatList.isEmpty ? null : () => _generateLaporanAlat(alatList),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateTotalDenda(List<Peminjaman> list) {
    return list.fold<int>(0, (sum, p) => sum + (p.totalDenda ?? 0));
  }

  void _generateLaporanPeminjaman(List<Peminjaman> list) {
    final laporanData = _buildLaporanPeminjamanData(list);
    _showLaporanPreview('Laporan Peminjaman', laporanData);
  }

  void _generateLaporanPengembalian(List<Peminjaman> list) {
    final laporanData = _buildLaporanPengembalianData(list);
    _showLaporanPreview('Laporan Pengembalian', laporanData);
  }

  void _generateLaporanDenda(List<Peminjaman> list) {
    final laporanData = _buildLaporanDendaData(list);
    _showLaporanPreview('Laporan Denda', laporanData);
  }

  void _generateLaporanAlat(List<Alat> list) {
    final laporanData = _buildLaporanAlatData(list);
    _showLaporanPreview('Laporan Status Alat', laporanData);
  }

  // ==================== BUILD LAPORAN DATA ====================

  List<Map<String, dynamic>> _buildLaporanPeminjamanData(List<Peminjaman> list) {
    final List<Map<String, dynamic>> data = [];
    
    data.add({
      'type': 'header',
      'title': 'LAPORAN PEMINJAMAN ALAT',
      'periode': 'Periode Aktif',
      'tanggal_cetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
    });

    data.add({
      'type': 'summary',
      'total_peminjaman': list.length,
      'menunggu': list.where((p) => p.status == 'menunggu').length,
      'disetujui': list.where((p) => p.status == 'disetujui').length,
      'sebagian': list.where((p) => p.status == 'sebagian').length,
      'selesai': list.where((p) => p.status == 'selesai').length,
      'ditolak': list.where((p) => p.status == 'ditolak').length,
    });

    data.add({'type': 'section_title', 'title': 'Detail Transaksi'});
    
    for (var p in list) {
      data.add({
        'type': 'detail',
        'id': p.id.substring(0, 8),
        'tanggal': DateFormat('dd/MM/yyyy').format(p.createdAt),
        'peminjam': p.peminjam?.displayName ?? p.peminjam?.email ?? '-',
        'jumlah_alat': p.items.length,
        'status': p.status.toUpperCase(),
        'petugas': p.petugas?.displayName ?? '-',
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanPengembalianData(List<Peminjaman> list) {
    final List<Map<String, dynamic>> data = [];
    
    final completedPeminjaman = list
        .where((p) => p.status == 'selesai' || p.status == 'sebagian')
        .toList();

    data.add({
      'type': 'header',
      'title': 'LAPORAN PENGEMBALIAN ALAT',
      'periode': 'Periode Aktif',
      'tanggal_cetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
    });

    data.add({
      'type': 'summary',
      'total_pengembalian': completedPeminjaman.length,
      'tepat_waktu': completedPeminjaman.where((p) => (p.totalDenda ?? 0) == 0).length,
      'terlambat': completedPeminjaman.where((p) => (p.totalDenda ?? 0) > 0).length,
    });

    data.add({'type': 'section_title', 'title': 'Detail Pengembalian'});
    
    for (var p in completedPeminjaman) {
      for (var item in p.items.where((i) => i.status == 'dikembalikan')) {
        data.add({
          'type': 'detail',
          'kode_alat': item.alat?.kode ?? '-',
          'nama_alat': item.alat?.nama ?? '-',
          'peminjam': p.peminjam?.displayName ?? p.peminjam?.email ?? '-',
          'tanggal_pinjam': DateFormat('dd/MM/yyyy').format(p.createdAt),
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

  List<Map<String, dynamic>> _buildLaporanDendaData(List<Peminjaman> list) {
    final List<Map<String, dynamic>> data = [];
    
    final peminjamanWithDenda = list
        .where((p) => (p.totalDenda ?? 0) > 0)
        .toList();

    final totalDenda = _calculateTotalDenda(list);

    data.add({
      'type': 'header',
      'title': 'LAPORAN DENDA PEMINJAMAN',
      'periode': 'Periode Aktif',
      'tanggal_cetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
    });

    data.add({
      'type': 'summary',
      'total_denda': totalDenda,
      'jumlah_transaksi': peminjamanWithDenda.length,
      'rata_rata_denda': peminjamanWithDenda.isEmpty 
          ? 0 
          : totalDenda ~/ peminjamanWithDenda.length,
    });

    data.add({'type': 'section_title', 'title': 'Detail Denda per Transaksi'});
    
    for (var p in peminjamanWithDenda) {
      data.add({
        'type': 'detail',
        'id_peminjaman': p.id.substring(0, 8),
        'peminjam': p.peminjam?.displayName ?? p.peminjam?.email ?? '-',
        'total_denda': 'Rp ${NumberFormat('#,###').format(p.totalDenda)}',
        'status': p.status.toUpperCase(),
      });
    }

    return data;
  }

  List<Map<String, dynamic>> _buildLaporanAlatData(List<Alat> list) {
    final List<Map<String, dynamic>> data = [];
    
    data.add({
      'type': 'header',
      'title': 'LAPORAN STATUS ALAT',
      'periode': 'Periode Aktif',
      'tanggal_cetak': DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now()),
    });

    data.add({
      'type': 'summary',
      'total_alat': list.length,
      'tersedia': list.where((a) => a.status == 'tersedia').length,
      'dipinjam': list.where((a) => a.status == 'dipinjam').length,
      'nonaktif': list.where((a) => a.status == 'nonaktif').length,
    });

    // Group by kategori
    final kategoriGroups = <String, List<Alat>>{};
    for (var alat in list) {
      final kategori = alat.namaKategori ?? 'Lainnya';
      kategoriGroups.putIfAbsent(kategori, () => []).add(alat);
    }

    for (var entry in kategoriGroups.entries) {
      data.add({'type': 'section_title', 'title': entry.key});
      
      for (var alat in entry.value) {
        data.add({
          'type': 'detail',
          'kode': alat.kode,
          'nama': alat.nama,
          'sub_kategori': alat.namaSubKategori ?? '-',
          'status': alat.status.toUpperCase(),
          'kondisi': alat.kondisi.toUpperCase(),
          'lokasi': alat.lokasiSimpan ?? '-',
        });
      }
    }

    return data;
  }

  // ==================== PREVIEW LAPORAN ====================

  void _showLaporanPreview(String title, List<Map<String, dynamic>> data) {
    Navigator.pop(context); // Tutup bottom sheet menu
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LaporanPreviewPage(title: title, data: data),
      ),
    );
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
                                    user.displayName ?? user.email,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print, color: Colors.white),
                                  tooltip: 'Cetak Laporan',
                                  onPressed: _showLaporanMenu,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  tooltip: 'Keluar',
                                  onPressed: _confirmLogout,
                                ),
                              ],
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: _showLaporanMenu,
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak Laporan'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: AppColors.secondary700,
                    ),
                  ),
                ),

                // Filter Chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                        selectedColor: (filter['color'] as Color).withValues(alpha: 0.1),
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
                      return const SizedBox.shrink();
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
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
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
                          const SnackBar(
                            content: Text('Status peminjaman diperbarui'),
                            backgroundColor: AppColors.success500,
                          ),
                        );
                        _loadData();
                      }
                    },
                    builder: (context, state) {
                      if (state is PeminjamanLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
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
                            child: const Text('Coba Lagi'),
                          ),
                        );
                      }

                      if (state is PeminjamanLoaded) {
                        if (state.peminjaman.isEmpty) {
                          return const EmptyState(
                            title: 'Tidak Ada Peminjaman',
                            subtitle: 'Tidak ada peminjaman dengan filter ini',
                            icon: Icons.inventory_2_outlined,
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.peminjaman.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final peminjaman = state.peminjaman[index];
                            return _PetugasPeminjamanCard(
                              peminjaman: peminjaman,
                              onApprove: peminjaman.status == 'menunggu'
                                  ? () => _showApproveDialog(peminjaman)
                                  : null,
                              onReject: peminjaman.status == 'menunggu'
                                  ? () => _showRejectDialog(peminjaman)
                                  : null,
                              onProcessReturn: (peminjaman.status == 'disetujui' || peminjaman.status == 'sebagian')
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

                      return const SizedBox.shrink();
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
        title: const Text('Setujui Peminjaman?'),
        content: Text(
          'Anda akan menyetujui peminjaman ${peminjaman.peminjam?.displayName ?? peminjaman.peminjam?.email} '
          'untuk ${peminjaman.items.length} alat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final user = (context.read<AuthCubit>().state as Authenticated).user;
              context.read<PeminjamanCubit>().approvePeminjaman(peminjaman.id, user.id);
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Peminjaman peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Peminjaman?'),
        content: const Text(
          'Anda akan menolak peminjaman ini. Alat tidak akan dipinjamkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
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
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}

// ==================== WIDGET LAPORAN ====================

class _LaporanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _LaporanCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.neutral400, size: 20),
        ],
      ),
    );
  }
}

// ==================== LAPORAN PREVIEW PAGE ====================

class _LaporanPreviewPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const _LaporanPreviewPage({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview $title'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bagikan laporan')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cetak laporan')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((item) => _buildLaporanItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildLaporanItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'header':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.primary600,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Periode: ${item['periode']}',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
              Text(
                'Dicetak: ${item['tanggal_cetak']}',
                style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        );

      case 'summary':
        return AppCard(
          color: AppColors.success50,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ringkasan', style: AppTypography.h4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: item.entries
                    .where((e) => e.key != 'type')
                    .map((e) => Chip(
                          label: Text('${e.key.replaceAll('_', ' ').toUpperCase()}: ${e.value}'),
                          backgroundColor: Colors.white,
                        ))
                    .toList(),
              ),
            ],
          ),
        );

      case 'section_title':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            item['title'],
            style: AppTypography.h4.copyWith(color: AppColors.primary700),
          ),
        );

      case 'detail':
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.entries
                .where((e) => e.key != 'type')
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${e.key.replaceAll('_', ' ').toUpperCase()}:',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${e.value}',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ==================== STAT CARD ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.h2.copyWith(color: color)),
              Text(title, style: AppTypography.labelMedium.copyWith(color: AppColors.neutral600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== PEMINJAMAN CARD ====================

class _PetugasPeminjamanCard extends StatelessWidget {
  final Peminjaman peminjaman;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onProcessReturn;
  final VoidCallback onTap;

  const _PetugasPeminjamanCard({
    required this.peminjaman,
    this.onApprove,
    this.onReject,
    this.onProcessReturn,
    required this.onTap,
  });

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
                      peminjaman.peminjam?.displayName ?? peminjaman.peminjam?.email ?? '-',
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
                '${peminjaman.items.length} Alat',
                style: AppTypography.bodyMedium,
              ),
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
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
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
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
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
                      icon: const Icon(Icons.assignment_return, size: 18),
                      label: const Text('Proses'),
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