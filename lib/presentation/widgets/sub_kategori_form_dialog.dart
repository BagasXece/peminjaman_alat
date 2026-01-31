// lib/presentation/widgets/sub_kategori_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kategori_alat.dart';
import '../../domain/entities/sub_kategori_alat.dart';
import '../blocs/kategori/kategori_cubit.dart';
import '../blocs/sub_kategori/sub_kategori_cubit.dart';

class SubKategoriFormDialog extends StatefulWidget {
  final SubKategoriAlat? subKategori;
  final List<KategoriAlat> kategoriList;

  const SubKategoriFormDialog({
    Key? key,
    this.subKategori,
    required this.kategoriList,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    SubKategoriAlat? subKategori,
    required List<KategoriAlat> kategoriList,
  }) {
    return showDialog(
      context: context,
      builder: (_) => SubKategoriFormDialog(
        subKategori: subKategori,
        kategoriList: kategoriList,
      ),
    );
  }

  @override
  State<SubKategoriFormDialog> createState() => _SubKategoriFormDialogState();
}

class _SubKategoriFormDialogState extends State<SubKategoriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  String? _selectedKategoriId;
  bool get isEdit => widget.subKategori != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _kodeController.text = widget.subKategori!.kode;
      _namaController.text = widget.subKategori!.nama;
      _selectedKategoriId = widget.subKategori!.kategoriId;
    } else if (widget.kategoriList.isNotEmpty) {
      _selectedKategoriId = widget.kategoriList.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Edit Sub Kategori' : 'Tambah Sub Kategori'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.kategoriList.isEmpty)
                const Text('Tidak ada kategori tersedia')
              else
                DropdownButtonFormField<String>(
                  value: _selectedKategoriId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Induk *',
                    prefixIcon: Icon(Icons.folder),
                  ),
                  items: widget.kategoriList
                      .map((k) => DropdownMenuItem(
                            value: k.id,
                            child: Text('${k.kode} - ${k.nama}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedKategoriId = val),
                  validator: (val) => val == null ? 'Pilih kategori' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Sub Kategori *',
                  hintText: 'Contoh: CNC',
                  prefixIcon: Icon(Icons.code),
                  helperText: 'Kode unik, akan digabung dengan kode kategori',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Kode wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sub Kategori *',
                  hintText: 'Contoh: Bubut CNC',
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nama wajib diisi';
                  return null;
                },
              ),
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
          onPressed: _selectedKategoriId == null ? null : _submit,
          child: Text(isEdit ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (isEdit) {
      context.read<SubKategoriCubit>().editSubKategorie(
        widget.subKategori!.id,
        kategoriId: _selectedKategoriId,
        kode: _kodeController.text,
        nama: _namaController.text,
      );
    } else {
      context.read<SubKategoriCubit>().addSubKategori(
        kategoriId: _selectedKategoriId!,
        kode: _kodeController.text,
        nama: _namaController.text,
      );
    }
    Navigator.pop(context);
  }
}