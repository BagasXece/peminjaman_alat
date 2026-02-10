// lib/presentation/pages/form_pengembalian_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
// import '../../domain/entities/peminjaman.dart';
import '../../../domain/entities/peminjaman_item.dart';
import '../../blocs/peminjaman/peminjaman_cubit.dart';
import '../../widgets/app_card.dart';
// import '../widgets/status_badge.dart';

class FormPengembalianPage extends StatefulWidget {
  final String peminjamanId;

  const FormPengembalianPage({
    Key? key,
    required this.peminjamanId,
  }) : super(key: key);

  @override
  State<FormPengembalianPage> createState() => _FormPengembalianPageState();
}

class _FormPengembalianPageState extends State<FormPengembalianPage> {
  final Set<String> _selectedItems = {};
  final TextEditingController _catatanController = TextEditingController();
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    context.read<PeminjamanCubit>().getPeminjamanDetail(widget.peminjamanId);
  }

  void _toggleSelectAll(List<PeminjamanItem> items) {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedItems.addAll(
          items.where((i) => i.status == 'dipinjam').map((i) => i.id),
        );
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _submitPengembalian() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih minimal 1 alat yang dikembalikan'),
          backgroundColor: AppColors.danger500,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pengembalian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan memproses pengembalian untuk:'),
            const SizedBox(height: 12),
            Text(
              '${_selectedItems.length} alat',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Total denda: Rp ${NumberFormat('#,###').format(_calculateTotalDenda())}',
              style: AppTypography.bodyLarge.copyWith(
                color: _calculateTotalDenda() > 0
                    ? AppColors.danger600
                    : AppColors.success600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PeminjamanCubit>().processPengembalian(
                    widget.peminjamanId,
                    _selectedItems.toList(),
                    catatan: _catatanController.text.isEmpty
                        ? null
                        : _catatanController.text,
                  );
            },
            child: Text('Proses'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalDenda() {
    final state = context.read<PeminjamanCubit>().state;
    if (state is! PeminjamanDetailLoaded) return 0;

    return state.peminjaman.items
        .where((item) => _selectedItems.contains(item.id))
        .fold<int>(0, (sum, item) => sum + item.calculateDenda(AppConstants.dendaPerHari));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proses Pengembalian'),
      ),
      body: BlocConsumer<PeminjamanCubit, PeminjamanState>(
        listener: (context, state) {
          if (state is PeminjamanUpdated) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success500,
                  size: 64,
                ),
                title: Text('Pengembalian Berhasil'),
                content: Text(
                  'Pengembalian telah diproses. '
                  '${state.peminjaman.status == 'selesai' ? 'Peminjaman selesai.' : 'Menunggu pengembalian sisa alat.'}',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is PeminjamanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger500,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PeminjamanLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is PeminjamanDetailLoaded) {
            final peminjaman = state.peminjaman;
            final activeItems =
                peminjaman.items.where((i) => i.status == 'dipinjam').toList();

            if (activeItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.success500,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Semua Alat Sudah Kembali',
                      style: AppTypography.h4,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Info Peminjam
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.info100,
                        child: Icon(Icons.person, color: AppColors.info600),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peminjam',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.info700,
                              ),
                            ),
                            Text(
                              peminjaman.peminjam?.displayNameOrEmail ?? '-',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Select All
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (_) => _toggleSelectAll(activeItems),
                      ),
                      Text(
                        'Pilih Semua',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedItems.length}/${activeItems.length} dipilih',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),

                // List Alat
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeItems.length,
                    itemBuilder: (context, index) {
                      final item = activeItems[index];
                      return _ReturnItemCard(
                        item: item,
                        isSelected: _selectedItems.contains(item.id),
                        denda: item.calculateDenda(AppConstants.dendaPerHari),
                        onToggle: () {
                          setState(() {
                            if (_selectedItems.contains(item.id)) {
                              _selectedItems.remove(item.id);
                              _selectAll = false;
                            } else {
                              _selectedItems.add(item.id);
                              if (_selectedItems.length == activeItems.length) {
                                _selectAll = true;
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

                // Summary & Submit
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Total Denda
                        if (_selectedItems.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _calculateTotalDenda() > 0
                                  ? AppColors.danger50
                                  : AppColors.success50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _calculateTotalDenda() > 0
                                    ? AppColors.danger200
                                    : AppColors.success200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Denda',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: _calculateTotalDenda() > 0
                                            ? AppColors.danger700
                                            : AppColors.success700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${NumberFormat('#,###').format(_calculateTotalDenda())}',
                                      style: AppTypography.h3.copyWith(
                                        color: _calculateTotalDenda() > 0
                                            ? AppColors.danger600
                                            : AppColors.success600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_calculateTotalDenda() > 0)
                                  Icon(
                                    Icons.warning_amber,
                                    color: AppColors.danger500,
                                    size: 32,
                                  )
                                else
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.success500,
                                    size: 32,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Catatan
                        TextField(
                          controller: _catatanController,
                          decoration: InputDecoration(
                            labelText: 'Catatan (Opsional)',
                            hintText: 'Tambahkan catatan kondisi alat...',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _selectedItems.isEmpty
                                ? null
                                : _submitPengembalian,
                            child: Text('Proses Pengembalian'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(child: Text('Gagal memuat data'));
        },
      ),
    );
  }
}

class _ReturnItemCard extends StatelessWidget {
  final PeminjamanItem item;
  final bool isSelected;
  final int denda;
  final VoidCallback onToggle;

  const _ReturnItemCard({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.denda,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    debugPrint('------------------------------');
  debugPrint('now: ${DateTime.now()}');
  debugPrint('now local: ${DateTime.now().toLocal()}');
  debugPrint('jatuhTempo: ${item.jatuhTempo}');
  debugPrint('jatuhTempo local: ${item.jatuhTempo.toLocal()}');
  debugPrint('------------------------------');
    final isTerlambat = item.isTerlambat;
    final dateFormat = DateFormat('dd MMM yyyy');

    return AppCard(
      color: isSelected ? AppColors.primary50 : Colors.white,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.alat?.nama ?? '-',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.alat?.kode ?? '-',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isTerlambat
                            ? AppColors.danger500
                            : AppColors.neutral500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Jatuh tempo: ${dateFormat.format(item.jatuhTempo)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isTerlambat
                              ? AppColors.danger600
                              : AppColors.neutral600,
                          fontWeight:
                              isTerlambat ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (isTerlambat) ...[
                    const SizedBox(height: 8),
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
                        'Terlambat ${item.hariTerlambat} hari • Denda: Rp ${NumberFormat('#,###').format(denda)}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.danger700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}