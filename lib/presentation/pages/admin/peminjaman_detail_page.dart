// lib/presentation/pages/admin/peminjaman_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/peminjaman/peminjaman_admin_cubit.dart';

class PeminjamanDetailPage extends StatelessWidget {
  final String id;
  const PeminjamanDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PeminjamanAdminCubit>().loadDetail(id),
          ),
        ],
      ),
      body: BlocBuilder<PeminjamanAdminCubit, PeminjamanAdminState>(
        builder: (context, state) {
          if (state is PeminjamanAdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PeminjamanAdminDetailLoaded) {
            final data = state.detail;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Info Peminjaman', style: Theme.of(context).textTheme.titleLarge),
                              Chip(label: Text(data.status.toUpperCase())),
                            ],
                          ),
                          const Divider(),
                          _infoRow('Kode', data.kodePeminjaman ?? '-'),
                          _infoRow('Peminjam', data.peminjam?.displayNameOrEmail ?? '-'),
                          _infoRow('Tanggal', DateFormat('dd MMMM yyyy, HH:mm').format(data.createdAt)),
                          if (data.petugas != null)
                            _infoRow('Disetujui Oleh', data.petugas!.displayNameOrEmail),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Items List
                  Text('Daftar Alat (${data.items.length})', 
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...data.items.map((item) => _ItemCard(
                    item: item,
                    onReturn: item.isDipinjam ? () => _processReturn(context, id, item.id) : null,
                    onExtend: item.isDipinjam ? () => _extendDialog(context, id, item) : null,
                  )),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (data.canApprove) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _confirmApprove(context, data.id),
                        icon: const Icon(Icons.check),
                        label: const Text('SETUJUI'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectDialog(context, data.id),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('TOLAK', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  ],

                  if (data.canReturn) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _batchReturnDialog(context, data),
                        icon: const Icon(Icons.assignment_return),
                        label: const Text('PROSES PENGEMBALIAN'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const Center(child: Text('Gagal memuat data'));
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _ItemCard({
    required var item, // PeminjamanItem
    VoidCallback? onReturn,
    VoidCallback? onExtend,
  }) {
    final isOverdue = item.isOverdue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: item.isDikembalikan ? Colors.green[50] : (isOverdue ? Colors.red[50] : null),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.alat?.nama ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isDikembalikan ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Kode: ${item.alat?.kode ?? '-'}'),
            Text(
              'Jatuh Tempo: ${DateFormat('dd/MM/yyyy').format(item.jatuhTempo)}',
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
            if (item.pengembalian != null) ...[
              Text('Dikembalikan: ${DateFormat('dd/MM/yyyy').format(item.pengembalian!.dikembalikanPada)}'),
              if (item.pengembalian!.totalDenda > 0)
                Text(
                  'Denda: Rp ${NumberFormat('#,###').format(item.pengembalian!.totalDenda)}',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
            if (onReturn != null || onExtend != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (onReturn != null)
                    TextButton.icon(
                      onPressed: onReturn,
                      icon: const Icon(Icons.assignment_return, size: 18),
                      label: const Text('Kembali'),
                    ),
                  if (onExtend != null) ...[
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: onExtend,
                      icon: const Icon(Icons.date_range, size: 18),
                      label: const Text('Perpanjang'),
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

  void _confirmApprove(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Setujui peminjaman ini?'),
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
          decoration: const InputDecoration(labelText: 'Alasan Penolakan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PeminjamanAdminCubit>().reject(id, controller.text);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  void _batchReturnDialog(BuildContext context, var data) {
    final selected = <String>[];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Pengembalian Batch'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: data.items.where((i) => i.isDipinjam).map((item) => CheckboxListTile(
                title: Text(item.alat?.nama ?? '-'),
                subtitle: Text('Jatuh tempo: ${DateFormat('dd/MM/yyyy').format(item.jatuhTempo)}'),
                value: selected.contains(item.id),
                onChanged: (val) {
                  setState(() {
                    if (val == true) selected.add(item.id);
                    else selected.remove(item.id);
                  });
                },
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: selected.isEmpty ? null : () {
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

  void _extendDialog(BuildContext context, String peminjamanId, var item) {
    final hariController = TextEditingController();
    final alasanController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perpanjang Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jatuh tempo saat ini: ${DateFormat('dd/MM/yyyy').format(item.jatuhTempo)}'),
            TextField(
              controller: hariController,
              decoration: const InputDecoration(labelText: 'Tambahan Hari'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: alasanController,
              decoration: const InputDecoration(labelText: 'Alasan'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final hari = int.tryParse(hariController.text) ?? 0;
              if (hari > 0) {
                Navigator.pop(ctx);
                context.read<PeminjamanAdminCubit>().extend(
                  peminjamanId, 
                  item.id, 
                  hari, 
                  alasanController.text,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}