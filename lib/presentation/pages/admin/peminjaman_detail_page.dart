// lib/presentation/pages/admin/peminjaman_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/peminjaman.dart';
import '../../../domain/entities/peminjaman_item.dart';
import '../../blocs/peminjaman/peminjaman_admin_cubit.dart';

class PeminjamanDetailPage extends StatefulWidget {
  final String id;
  const PeminjamanDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<PeminjamanDetailPage> createState() => _PeminjamanDetailPageState();
}

class _PeminjamanDetailPageState extends State<PeminjamanDetailPage> {
  @override
  void initState() {
    super.initState();
    // PENTING: Load detail saat page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeminjamanAdminCubit>().loadDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PeminjamanAdminCubit>().loadDetail(widget.id),
          ),
        ],
      ),
      body: BlocConsumer<PeminjamanAdminCubit, PeminjamanAdminState>(
        listener: (context, state) {
          if (state is PeminjamanAdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          // Loading State
          if (state is PeminjamanAdminLoading || state is PeminjamanAdminInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error State - Tampilkan retry
          if (state is PeminjamanAdminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data',
                      style: AppTypography.h4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<PeminjamanAdminCubit>().loadDetail(widget.id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Success State
          if (state is PeminjamanAdminDetailLoaded) {
            final data = state.detail;
            return _buildContent(context, data);
          }

          // Fallback jika state tidak dikenali
          return const Center(child: Text('Gagal memuat data'));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Peminjaman data) {
    final currencyFormat = NumberFormat('#,###');
    
    return RefreshIndicator(
      onRefresh: () => context.read<PeminjamanAdminCubit>().loadDetail(widget.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.neutral200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Info Peminjaman', 
                          style: AppTypography.h4
                        ),
                        _buildStatusChip(data.status),
                      ],
                    ),
                    const Divider(height: 24),
                    _infoRow('Kode', data.kodePeminjaman ?? '-'),
                    _infoRow('Peminjam', data.peminjam?.displayNameOrEmail ?? '-'),
                    _infoRow(
                      'Tanggal Pengajuan', 
                      DateFormat('dd MMMM yyyy, HH:mm').format(data.createdAt)
                    ),
                    if (data.petugas != null)
                      _infoRow('Disetujui Oleh', data.petugas!.displayNameOrEmail),
                    if (data.disetujuiPada != null)
                      _infoRow(
                        'Waktu Persetujuan',
                        DateFormat('dd MMMM yyyy, HH:mm').format(data.disetujuiPada!)
                      ),
                    if (data.totalDenda > 0)
                      _infoRow(
                        'Total Denda',
                        'Rp ${currencyFormat.format(data.totalDenda)}',
                        valueColor: AppColors.danger600,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Items List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Alat (${data.items.length})', 
                  style: AppTypography.h4,
                ),
                if (data.canApprove || data.canReturn)
                  Text(
                    'Aksi tersedia',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.success600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // List Items
            ...data.items.map((item) => _ItemCard(
              item: item,
              onReturn: item.status == 'dipinjam' && data.canReturn 
                  ? () => _processReturn(context, data.id, item.id) 
                  : null,
              onExtend: item.status == 'dipinjam' && data.canReturn 
                  ? () => _extendDialog(context, data.id, item) 
                  : null,
            )),

            const SizedBox(height: 24),

            // Action Buttons
            if (data.canApprove) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _confirmApprove(context, data.id),
                  icon: const Icon(Icons.check),
                  label: const Text('SETUJUI PEMINJAMAN'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.success600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _rejectDialog(context, data.id),
                  icon: Icon(Icons.close, color: AppColors.danger600),
                  label: Text(
                    'TOLAK PEMINJAMAN', 
                    style: TextStyle(color: AppColors.danger600)
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.danger600),
                  ),
                ),
              ),
            ],

            if (data.canReturn && data.items.any((i) => i.status == 'dipinjam')) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _batchReturnDialog(context, data),
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('PROSES PENGEMBALIAN BATCH'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.info600),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
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
        color = AppColors.success600;
        break;
      case 'selesai':
        color = AppColors.primary600;
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
        style: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, 
            child: Text(
              label, 
              style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600)
            )
          ),
          Expanded(
            child: Text(
              value, 
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _ItemCard({
    required PeminjamanItem item,
    VoidCallback? onReturn,
    VoidCallback? onExtend,
  }) {
    final isDikembalikan = item.status == 'dikembalikan';
    final isDipinjam = item.status == 'dipinjam';
    final isOverdue = isDipinjam && item.jatuhTempo.isBefore(DateTime.now());
    final currencyFormat = NumberFormat('#,###');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDikembalikan 
          ? AppColors.success50 
          : (isOverdue ? AppColors.danger50 : null),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDikembalikan 
              ? AppColors.success200 
              : (isOverdue ? AppColors.danger200 : AppColors.neutral200),
        ),
      ),
      child: Padding(
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
                        item.alat?.nama ?? '-',
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.alat?.kode ?? '-',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ),
                _buildItemStatusChip(item.status, isOverdue: isOverdue),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildItemInfo(
                    'Jatuh Tempo',
                    DateFormat('dd/MM/yyyy').format(item.jatuhTempo),
                    isDanger: isOverdue,
                  ),
                ),
                if (item.dikembalikanPada != null)
                  Expanded(
                    child: _buildItemInfo(
                      'Dikembalikan',
                      DateFormat('dd/MM/yyyy').format(item.dikembalikanPada!),
                    ),
                  ),
              ],
            ),
            
            // Denda Info
            if (item.totalDenda != null && item.totalDenda! > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, size: 16, color: AppColors.danger600),
                        const SizedBox(width: 8),
                        Text(
                          'Terlambat ${item.terlambatHari} hari',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.danger700),
                        ),
                      ],
                    ),
                    Text(
                      'Denda: Rp ${currencyFormat.format(item.totalDenda)}',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.danger700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Action Buttons
            if (onReturn != null || onExtend != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onReturn != null)
                    TextButton.icon(
                      onPressed: onReturn,
                      icon: const Icon(Icons.assignment_return, size: 18),
                      label: const Text('Kembalikan'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.info600),
                    ),
                  if (onExtend != null) ...[
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: onExtend,
                      icon: const Icon(Icons.date_range, size: 18),
                      label: const Text('Perpanjang'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.secondary600),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemStatusChip(String status, {bool isOverdue = false}) {
    Color color;
    String label = status.toUpperCase();
    
    switch (status) {
      case 'dipinjam':
        color = isOverdue ? AppColors.danger600 : AppColors.warning600;
        if (isOverdue) label = 'TERLAMBAT';
        break;
      case 'dikembalikan':
        color = AppColors.success600;
        break;
      default:
        color = AppColors.neutral600;
    }
    
    return Chip(
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildItemInfo(String label, String value, {bool isDanger = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDanger ? AppColors.danger600 : AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  void _confirmApprove(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: const Text('Anda yakin ingin menyetujui peminjaman ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PeminjamanAdminCubit>().approve(id);
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _rejectDialog(BuildContext context, String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Peminjaman'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Alasan Penolakan',
            hintText: 'Masukkan alasan menolak peminjaman',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<PeminjamanAdminCubit>().reject(id, controller.text);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _processReturn(BuildContext context, String peminjamanId, String itemId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Proses Pengembalian'),
        content: const Text('Yakin ingin memproses pengembalian alat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PeminjamanAdminCubit>().processReturn(peminjamanId, [itemId]);
            },
            child: const Text('Proses'),
          ),
        ],
      ),
    );
  }

  void _batchReturnDialog(BuildContext context, Peminjaman data) {
    final selected = <String>[];
    final dipinjamItems = data.items.where((i) => i.status == 'dipinjam').toList();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Pengembalian Batch'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: dipinjamItems.isEmpty 
                ? const Center(child: Text('Tidak ada alat yang sedang dipinjam'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: dipinjamItems.length,
                    itemBuilder: (_, index) {
                      final item = dipinjamItems[index];
                      return CheckboxListTile(
                        title: Text(item.alat?.nama ?? '-'),
                        subtitle: Text(
                          'Jatuh tempo: ${DateFormat('dd/MM/yyyy').format(item.jatuhTempo)}',
                          style: TextStyle(
                            color: item.jatuhTempo.isBefore(DateTime.now()) 
                                ? Colors.red 
                                : null,
                          ),
                        ),
                        value: selected.contains(item.id),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) selected.add(item.id);
                            else selected.remove(item.id);
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: selected.isEmpty || dipinjamItems.isEmpty 
                  ? null 
                  : () {
                      Navigator.pop(ctx);
                      context.read<PeminjamanAdminCubit>().processReturn(data.id, selected);
                    },
              child: Text('Proses (${selected.length})'),
            ),
          ],
        ),
      ),
    );
  }

  void _extendDialog(BuildContext context, String peminjamanId, PeminjamanItem item) {
    final hariController = TextEditingController();
    final alasanController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perpanjang Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jatuh tempo saat ini:',
              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(item.jatuhTempo),
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hariController,
              decoration: const InputDecoration(
                labelText: 'Tambahan Hari',
                hintText: 'Contoh: 3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              decoration: const InputDecoration(
                labelText: 'Alasan Perpanjangan',
                hintText: 'Contoh: Project belum selesai',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final hari = int.tryParse(hariController.text) ?? 0;
              if (hari <= 0 || hari > 7) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perpanjangan harus 1-7 hari')),
                );
                return;
              }
              if (alasanController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<PeminjamanAdminCubit>().extend(
                peminjamanId, 
                item.id, 
                hari, 
                alasanController.text,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}