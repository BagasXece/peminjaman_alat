// lib/presentation/pages/form_peminjaman_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
// import '../../core/constants/app_constants.dart';
import '../../../domain/entities/alat.dart';
import '../../blocs/alat/alat_cubit.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/peminjaman/peminjaman_cubit.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({Key? key}) : super(key: key);

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final Map<String, Alat> _selectedAlat = {};
  final Map<String, DateTime> _jatuhTempoMap = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AlatCubit>().loadAlat(status: 'tersedia');
  }

  void _selectAlat(Alat alat) {
    setState(() {
      if (_selectedAlat.containsKey(alat.id)) {
        _selectedAlat.remove(alat.id);
        _jatuhTempoMap.remove(alat.id);
      } else {
        _selectedAlat[alat.id] = alat;
        _jatuhTempoMap[alat.id] = DateTime.now().add(Duration(days: 7));
      }
    });
  }

  Future<void> _selectDate(BuildContext context, String alatId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _jatuhTempoMap[alatId] ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary600,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _jatuhTempoMap[alatId] = picked;
      });
    }
  }

    void _submitPeminjaman() {
    if (_selectedAlat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih minimal 1 alat'),
          backgroundColor: AppColors.danger500,
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    // Konversi ke list items
    final items = _selectedAlat.entries.map((entry) {
      return {
        'alatId': entry.key,
        'jatuhTempo': _jatuhTempoMap[entry.key] ?? DateTime.now().add(Duration(days: 7)),
      };
    }).toList();

    // Panggil dengan hanya 2 parameter: userId dan items
    context.read<PeminjamanCubit>().createPeminjaman(
      authState.user.id, 
      items,  // items diproses di cubit
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajukan Peminjaman'),
        actions: [
          if (_selectedAlat.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text(
                    '${_selectedAlat.length} dipilih',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primary600,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<PeminjamanCubit, PeminjamanState>(
        listener: (context, state) {
          if (state is PeminjamanCreated) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success500,
                  size: 64,
                ),
                title: Text('Peminjaman Berhasil'),
                content: Text(
                  'Pengajuan peminjaman Anda telah dikirim dan sedang menunggu persetujuan petugas.',
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
          // } else if (state is PeminjamanError) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(state.message),
          //       backgroundColor: AppColors.danger500,
          //     ),
          //   );
          }
        },
        builder: (context, peminjamanState) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
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
                  onChanged: (value) {
                    context.read<AlatCubit>().loadAlat(search: value);
                  },
                ),
              ),

              // Selected Items Summary (if any)
              if (_selectedAlat.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alat Terpilih',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._selectedAlat.entries.map((entry) {
                        final alat = entry.value;
                        final jatuhTempo = _jatuhTempoMap[entry.key]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alat.nama,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      alat.kode,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _selectDate(context, entry.key),
                                icon: Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  DateFormat('dd/MM/yyyy').format(jatuhTempo),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.danger500,
                                ),
                                onPressed: () => _selectAlat(alat),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Alat List
              Expanded(
                child: BlocBuilder<AlatCubit, AlatState>(
                  builder: (context, state) {
                    if (state is AlatLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state is AlatError) {
                      return EmptyState(
                        title: 'Terjadi Kesalahan',
                        subtitle: state.message,
                        icon: Icons.error_outline,
                        action: ElevatedButton(
                          onPressed: () => context.read<AlatCubit>().loadAlat(),
                          child: Text('Coba Lagi'),
                        ),
                      );
                    }

                    if (state is AlatLoaded) {
                      final availableAlat = state.alat
                          .where((a) => !_selectedAlat.containsKey(a.id))
                          .toList();

                      if (availableAlat.isEmpty) {
                        return EmptyState(
                          title: 'Tidak Ada Alat Tersedia',
                          subtitle: 'Semua alat sedang dipinjam atau tidak tersedia',
                          icon: Icons.inventory_2_outlined,
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableAlat.length,
                        itemBuilder: (context, index) {
                          final alat = availableAlat[index];
                          return _AlatSelectionCard(
                            alat: alat,
                            isSelected: false,
                            onTap: () => _selectAlat(alat),
                          );
                        },
                      );
                    }

                    return SizedBox.shrink();
                  },
                ),
              ),

              // Submit Button
              if (_selectedAlat.isNotEmpty)
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: peminjamanState is PeminjamanLoading
                            ? null
                            : _submitPeminjaman,
                        child: peminjamanState is PeminjamanLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text('Ajukan Peminjaman'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AlatSelectionCard extends StatelessWidget {
  final Alat alat;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlatSelectionCard({
    Key? key,
    required this.alat,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.precision_manufacturing,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.nama,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  alat.kode,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(status: alat.status),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: AppColors.neutral400),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alat.namaKategori ?? '-',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            isSelected
                ? Icons.check_circle
                : Icons.add_circle_outline,
            color: isSelected ? AppColors.success500 : AppColors.primary600,
            size: 28,
          ),
        ],
      ),
    );
  }
}