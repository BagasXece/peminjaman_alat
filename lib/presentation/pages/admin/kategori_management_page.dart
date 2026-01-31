// lib/presentation/pages/admin/kategori_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/kategori_alat.dart';
import '../../../domain/entities/sub_kategori_alat.dart';
import '../../blocs/kategori/kategori_cubit.dart';
import '../../blocs/sub_kategori/sub_kategori_cubit.dart';
import '../../widgets/app_card.dart';
import '../../widgets/kategori_form_dialog.dart';
import '../../widgets/sub_kategori_form_dialog.dart';

class KategoriManagementPage extends StatefulWidget {
  const KategoriManagementPage({Key? key}) : super(key: key);

  @override
  State<KategoriManagementPage> createState() => _KategoriManagementPageState();
}

class _KategoriManagementPageState extends State<KategoriManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<KategoriCubit>().loadKategori();
    context.read<SubKategoriCubit>().loadSubKategori();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<KategoriCubit, KategoriState>(
          listener: (context, state) {
            if (state is KategoriActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is KategoriError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
        BlocListener<SubKategoriCubit, SubKategoriState>(
          listener: (context, state) {
            if (state is SubKategoriActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is SubKategoriError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<KategoriCubit, KategoriState>(
        builder: (context, kategoriState) {
          return BlocBuilder<SubKategoriCubit, SubKategoriState>(
            builder: (context, subKategoriState) {
              final isMobile = MediaQuery.of(context).size.width < 640;
              
              final kategoriList = kategoriState is KategoriLoaded 
                  ? kategoriState.kategoriList 
                  : <KategoriAlat>[];
              final subKategoriList = subKategoriState is SubKategoriLoaded 
                  ? subKategoriState.subKategoriList 
                  : <SubKategoriAlat>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manajemen Kategori',
                          style: isMobile ? AppTypography.h3 : AppTypography.h2,
                        ),
                        if (!isMobile) ...[
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => KategoriFormDialog.show(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Kategori'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => SubKategoriFormDialog.show(
                                  context,
                                  kategoriList: kategoriList,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Sub Kategori'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isMobile) ...[
                      ElevatedButton.icon(
                        onPressed: () => KategoriFormDialog.show(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kategori'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => SubKategoriFormDialog.show(
                          context, 
                          kategoriList: kategoriList,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Sub Kategori'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (kategoriState is KategoriLoading || subKategoriState is SubKategoriLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _buildKategoriSection(isMobile, kategoriList),
                      const SizedBox(height: 24),
                      _buildSubKategoriSection(isMobile, subKategoriList, kategoriList),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKategoriSection(bool isMobile, List<KategoriAlat> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: AppTypography.h4),
        const SizedBox(height: 8),
        if (isMobile)
          Column(
            children: list.map((k) => _KategoriCardMobile(
              kategori: k,
              onEdit: () => KategoriFormDialog.show(context, kategori: k),
              onDelete: () => _confirmDeleteKategori(context, k),
            )).toList(),
          )
        else
          AppCard(
            child: Column(
              children: list.map((k) => _KategoriItem(
                kategori: k,
                onEdit: () => KategoriFormDialog.show(context, kategori: k),
                onDelete: () => _confirmDeleteKategori(context, k),
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubKategoriSection(bool isMobile, List<SubKategoriAlat> list, List<KategoriAlat> kategoriList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sub Kategori', style: AppTypography.h4),
        const SizedBox(height: 8),
        if (isMobile)
          Column(
            children: list.map((sk) => _SubKategoriCardMobile(
              subKategori: sk,
              onEdit: () => SubKategoriFormDialog.show(
                context, 
                subKategori: sk,
                kategoriList: kategoriList,
              ),
              onDelete: () => _confirmDeleteSubKategori(context, sk),
            )).toList(),
          )
        else
          AppCard(
            child: Column(
              children: list.map((sk) => _SubKategoriItem(
                subKategori: sk,
                onEdit: () => SubKategoriFormDialog.show(
                  context,
                  subKategori: sk,
                  kategoriList: kategoriList,
                ),
                onDelete: () => _confirmDeleteSubKategori(context, sk),
              )).toList(),
            ),
          ),
      ],
    );
  }

  void _confirmDeleteKategori(BuildContext context, KategoriAlat kategori) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Yakin ingin menghapus ${kategori.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<KategoriCubit>().removeKategori(kategori.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubKategori(BuildContext context, SubKategoriAlat sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Sub Kategori?'),
        content: Text('Yakin ingin menghapus ${sub.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubKategoriCubit>().removeSubKategori(sub.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger600),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Widget Components
class _KategoriItem extends StatelessWidget {
  final KategoriAlat kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KategoriItem({
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary100,
        child: Text(kategori.kode, style: TextStyle(fontSize: 10, color: AppColors.primary700)),
      ),
      title: Text(kategori.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: onEdit),
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _KategoriCardMobile extends StatelessWidget {
  final KategoriAlat kategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KategoriCardMobile({
    required this.kategori,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary100,
          child: Text(kategori.kode, style: TextStyle(fontSize: 10, color: AppColors.primary700)),
        ),
        title: Text(kategori.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Row(
              children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
            )),
            PopupMenuItem(value: 'delete', child: Row(
              children: [Icon(Icons.delete, size: 18, color: AppColors.danger600), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.danger600))],
            )),
          ],
        ),
      ),
    );
  }
}

class _SubKategoriItem extends StatelessWidget {
  final SubKategoriAlat subKategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubKategoriItem({
    required this.subKategori,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.secondary100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          subKategori.kode,
          style: TextStyle(fontSize: 10, color: AppColors.secondary700, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(subKategori.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subKategori.namaKategori ?? '-', style: AppTypography.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: Icon(Icons.edit, size: 20), onPressed: onEdit),
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: AppColors.danger500),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SubKategoriCardMobile extends StatelessWidget {
  final SubKategoriAlat subKategori;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubKategoriCardMobile({
    required this.subKategori,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            subKategori.kode,
            style: TextStyle(fontSize: 10, color: AppColors.secondary700, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(subKategori.nama, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('${subKategori.kodeKategori} - ${subKategori.namaKategori}', style: AppTypography.bodySmall),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Row(
              children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
            )),
            PopupMenuItem(value: 'delete', child: Row(
              children: [Icon(Icons.delete, size: 18, color: AppColors.danger600), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.danger600))],
            )),
          ],
        ),
      ),
    );
  }
}