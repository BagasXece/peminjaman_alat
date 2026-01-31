// lib/presentation/widgets/kategori_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kategori_alat.dart';
import '../blocs/kategori/kategori_cubit.dart';

class KategoriFormDialog extends StatefulWidget {
  final KategoriAlat? kategori;

  const KategoriFormDialog({Key? key, this.kategori}) : super(key: key);

  static Future<void> show(BuildContext context, {KategoriAlat? kategori}) {
    return showDialog(
      context: context,
      builder: (_) => KategoriFormDialog(kategori: kategori),
    );
  }

  @override
  State<KategoriFormDialog> createState() => _KategoriFormDialogState();
}

class _KategoriFormDialogState extends State<KategoriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  bool get isEdit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _kodeController.text = widget.kategori!.kode;
      _namaController.text = widget.kategori!.nama;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _kodeController,
              decoration: const InputDecoration(
                labelText: 'Kode Kategori *',
                hintText: 'Contoh: BT',
                prefixIcon: Icon(Icons.code),
                helperText: '2-3 karakter unik',
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Kode wajib diisi';
                if (val.length < 2) return 'Minimal 2 karakter';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori *',
                hintText: 'Contoh: Mesin Bubut',
                prefixIcon: Icon(Icons.category),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Nama wajib diisi';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (isEdit) {
      context.read<KategoriCubit>().editKategori(
        widget.kategori!.id,
        kode: _kodeController.text,
        nama: _namaController.text,
      );
    } else {
      context.read<KategoriCubit>().addKategori(
        kode: _kodeController.text,
        nama: _namaController.text,
      );
    }
    Navigator.pop(context);
  }
}