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
  
  const AlatFormDialog({Key? key, this.alat}) : super(key: key);

  @override
  State<AlatFormDialog> createState() => _AlatFormDialogState();
}

class _AlatFormDialogState extends State<AlatFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  
  String? _selectedSubKategoriId;
  String _selectedKondisi = 'baik';
  bool _isLoading = false;
  
  bool get isEdit => widget.alat != null;

  @override
  void initState() {
    super.initState();
    // Load sub kategori
    context.read<SubKategoriCubit>().loadSubKategori();
    
    if (isEdit) {
      _namaController.text = widget.alat!.nama;
      _lokasiController.text = widget.alat!.lokasiSimpan ?? '';
      _selectedSubKategoriId = widget.alat!.subKategoriId;
      _selectedKondisi = widget.alat!.kondisi;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  prefixIcon: Icon(Icons.precision_manufacturing),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama alat wajib diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
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
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: subKategoriList.map((sub) => DropdownMenuItem(
                      value: sub.id,
                      child: Text('${sub.kode} - ${sub.nama} (${sub.namaKategori ?? '-'})'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedSubKategoriId = val),
                    validator: (value) => value == null ? 'Pilih sub kategori' : null,
                  );
                },
              ),
              SizedBox(height: 16),
              
              // Lokasi
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Penyimpanan',
                  hintText: 'Contoh: Gudang A - Rak 12',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              
              // Kondisi
              Text('Kondisi Alat', style: AppTypography.labelLarge),
              SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'baik',
                    label: Text('Baik'),
                    icon: Icon(Icons.check_circle, color: AppColors.success600),
                  ),
                  ButtonSegment(
                    value: 'rusak',
                    label: Text('Rusak'),
                    icon: Icon(Icons.warning, color: AppColors.warning600),
                  ),
                  ButtonSegment(
                    value: 'hilang',
                    label: Text('Hilang'),
                    icon: Icon(Icons.error, color: AppColors.danger600),
                  ),
                ],
                selected: {_selectedKondisi},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedKondisi = newSelection.first;
                  });
                },
              ),
              
              if (isEdit && widget.alat!.status == 'dipinjam' && _selectedKondisi != 'baik')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Alat sedang dipinjam. Perubahan kondisi akan otomatis mengupdate status saat dikembalikan.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.warning600),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isEdit ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    if (isEdit) {
      context.read<AlatCubit>().editAlat(
        id: widget.alat!.id,
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        kondisi: _selectedKondisi,
        subKategoriId: _selectedSubKategoriId,
      );
    } else {
      context.read<AlatCubit>().addAlat(
        nama: _namaController.text,
        subKategoriId: _selectedSubKategoriId!,
        lokasi: _lokasiController.text,
        kondisi: _selectedKondisi,
      );
    }
    
    Navigator.pop(context);
  }
}