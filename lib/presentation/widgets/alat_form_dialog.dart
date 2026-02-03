// lib/presentation/widgets/alat_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/alat.dart';
import '../../../domain/entities/sub_kategori_alat.dart';
import '../blocs/alat/alat_cubit.dart';
import '../blocs/sub_kategori/sub_kategori_cubit.dart';

class AlatFormDialog extends StatefulWidget {
  final Alat? alat;
  final bool isKondisiOnly; // Mode khusus update kondisi
  
  const AlatFormDialog({
    Key? key, 
    this.alat,
    this.isKondisiOnly = false,
  }) : super(key: key);

  @override
  State<AlatFormDialog> createState() => _AlatFormDialogState();
}

class _AlatFormDialogState extends State<AlatFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _catatanController = TextEditingController(); // Untubg kondisi
  
  String? _selectedSubKategoriId;
  String _selectedKondisi = 'baik';
  bool _isLoading = false;
  
  bool get isEdit => widget.alat != null;
  bool get isKondisiMode => widget.isKondisiOnly;

  @override
  void initState() {
    super.initState();
    
    if (isEdit) {
      _namaController.text = widget.alat!.nama;
      _lokasiController.text = widget.alat!.lokasiSimpan ?? '';
      _selectedSubKategoriId = widget.alat!.subKategoriId;
      _selectedKondisi = widget.alat!.kondisi;
    }
    
    // Kondisi mode: hanya load sub kategori untuk display
    if (!isKondisiMode) {
      context.read<SubKategoriCubit>().loadSubKategori();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mode kondisi only: form sederhana hanya untuk ubah kondisi
    if (isKondisiMode) {
      return _buildKondisiOnlyForm();
    }
    
    // Mode normal: form lengkap
    return _buildFullForm();
  }

  Widget _buildKondisiOnlyForm() {
    return AlertDialog(
      title: Text(
        'Update Kondisi: ${widget.alat!.nama}',
        style: AppTypography.h4,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info current
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kode: ${widget.alat!.kode}', style: AppTypography.bodySmall),
                  Text('Kondisi Saat Ini: ${widget.alat!.kondisi.toUpperCase()}'),
                  Text('Status Saat Ini: ${widget.alat!.status}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Pilihan kondisi baru
            Text('Kondisi Baru', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'baik',
                  label: const Text('Baik'),
                  icon: Icon(Icons.check_circle, color: AppColors.success600),
                ),
                ButtonSegment(
                  value: 'rusak',
                  label: const Text('Rusak'),
                  icon: Icon(Icons.warning, color: AppColors.warning600),
                ),
                ButtonSegment(
                  value: 'hilang',
                  label: const Text('Hilang'),
                  icon: Icon(Icons.error, color: AppColors.danger600),
                ),
              ],
              selected: {_selectedKondisi},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedKondisi = newSelection.first);
              },
            ),
            
            // Warning jika rusak/hilang
            if (_selectedKondisi != 'baik') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Status akan berubah menjadi "Tidak Tersedia"',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Alat ini tidak akan bisa dipinjam sampai kondisi diperbaiki.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Catatan
            const SizedBox(height: 16),
            TextFormField(
              controller: _catatanController,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Contoh: Layar pecah, keyboard rusak...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),
            
            // Warning jika sedang dipinjam
            if (widget.alat!.status == 'dipinjam') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger200),
                ),
                child: Text(
                  '⚠️ Alat sedang dipinjam! Perubahan kondisi akan diterapkan saat alat dikembalikan.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.danger700),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitKondisi,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Update Kondisi'),
        ),
      ],
    );
  }

  Widget _buildFullForm() {
    // ... form lengkap seperti sebelumnya, tapi TANPA field kondisi!
    // Kondisi hanya diubah via mode khusus
    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Alat' : 'Tambah Alat Baru',
        style: AppTypography.h4,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Alat
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Alat *',
                  hintText: 'Contoh: Mesin Bubut CNC V-500',
                  prefixIcon: const Icon(Icons.precision_manufacturing),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama alat wajib diisi';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sub Kategori Dropdown
              BlocBuilder<SubKategoriCubit, SubKategoriState>(
                builder: (context, state) {
                  List<SubKategoriAlat> subKategoriList = [];
                  if (state is SubKategoriLoaded) {
                    subKategoriList = state.subKategoriList;
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSubKategoriId,
                    decoration: InputDecoration(
                      labelText: 'Sub Kategori *',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: subKategoriList.map((sub) => DropdownMenuItem(
                      value: sub.id,
                      child: Text('${sub.kode} - ${sub.nama} (${sub.namaKategori ?? '-'})'),
                    )).toList(),
                    onChanged: isEdit ? null : (val) => setState(() => _selectedSubKategoriId = val), // Disable if edit
                    validator: (value) => value == null ? 'Pilih sub kategori' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Lokasi
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Penyimpanan',
                  hintText: 'Contoh: Gudang A - Rak 12',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              // Info: Kondisi diubah via menu terpisah
              if (isEdit) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Untuk mengubah kondisi alat, gunakan menu "Update Kondisi"',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.info700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitFull,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isEdit ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  void _submitKondisi() {
    if (_selectedKondisi == widget.alat!.kondisi) {
      Navigator.pop(context); // Tidak ada perubahan
      return;
    }
    
    setState(() => _isLoading = true);
    
    // ✅ Gunakan cubit method khusus update kondisi
    context.read<AlatCubit>().updateKondisiAlat(
      widget.alat!.id,
      _selectedKondisi,
      catatan: _catatanController.text.isNotEmpty 
          ? _catatanController.text 
          : null,
    );
    
    Navigator.pop(context);
  }

  void _submitFull() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    if (isEdit) {
      // ❌ Tidak kirim kondisi!
      context.read<AlatCubit>().editAlat(
        id: widget.alat!.id,
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        // kondisi: TIDAK ADA!
      );
    } else {
      // Create baru default kondisi 'baik'
      context.read<AlatCubit>().addAlat(
        nama: _namaController.text,
        subKategoriId: _selectedSubKategoriId!,
        lokasi: _lokasiController.text,
        kondisi: 'baik', // Default untuk alat baru
      );
    }
    
    Navigator.pop(context);
  }
}