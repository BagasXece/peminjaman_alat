// lib/presentation/pages/detail_peminjaman_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:peminjaman_alat/presentation/pages/pengembalian/form_pengembalian_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/peminjaman.dart';
import '../../../domain/entities/peminjaman_item.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/peminjaman/peminjaman_cubit.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class DetailPeminjamanPage extends StatefulWidget {
  final String peminjamanId;

  const DetailPeminjamanPage({
    Key? key,
    required this.peminjamanId,
  }) : super(key: key);

  @override
  State<DetailPeminjamanPage> createState() => _DetailPeminjamanPageState();
}

class _DetailPeminjamanPageState extends State<DetailPeminjamanPage> {
  @override
  void initState() {
    super.initState();
    context.read<PeminjamanCubit>().getPeminjamanDetail(widget.peminjamanId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        (context.read<AuthCubit>().state as Authenticated).user;
    final isPetugas = currentUser.role == AppConstants.rolePetugas ||
        currentUser.role == AppConstants.roleAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Peminjaman'),
      ),
      body: BlocBuilder<PeminjamanCubit, PeminjamanState>(
        builder: (context, state) {
          if (state is PeminjamanLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is PeminjamanDetailLoaded) {
            final peminjaman = state.peminjaman;
            final currencyFormat = NumberFormat('#,###');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Status
                  AppCard(
                    color: _getStatusColor(peminjaman.status).withOpacity(0.05),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        StatusBadge(
                          status: peminjaman.status,
                          isLarge: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          peminjaman.statusDisplay,
                          style: AppTypography.h3.copyWith(
                            color: _getStatusColor(peminjaman.status),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${peminjaman.id.substring(0, 8)}...',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Section
                  _SectionTitle('Informasi Peminjaman'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    rows: [
                      _InfoRow(
                        label: 'Peminjam',
                        value: peminjaman.peminjam?.displayNameOrEmail ?? '-',
                        icon: Icons.person_outline,
                      ),
                      if (peminjaman.petugas != null)
                        _InfoRow(
                          label: 'Disetujui Oleh',
                          value: peminjaman.petugas!.displayNameOrEmail,
                          icon: Icons.badge_outlined,
                        ),
                      if (peminjaman.disetujuiPada != null)
                        _InfoRow(
                          label: 'Waktu Persetujuan',
                          value: DateFormat('dd MMM yyyy, HH:mm')
                              .format(peminjaman.disetujuiPada!),
                          icon: Icons.check_circle_outline,
                        ),
                      _InfoRow(
                        label: 'Waktu Pengajuan',
                        value: DateFormat('dd MMM yyyy, HH:mm')
                            .format(peminjaman.createdAt),
                        icon: Icons.access_time,
                      ),
                      _InfoRow(
                        label: 'Total Alat',
                        value: '${peminjaman.totalItems} unit',
                        icon: Icons.build_circle_outlined,
                      ),
                      if (peminjaman.totalDenda != null &&
                          peminjaman.totalDenda! > 0)
                        _InfoRow(
                          label: 'Total Denda',
                          value: 'Rp ${currencyFormat.format(peminjaman.totalDenda)}',
                          icon: Icons.money_off,
                          valueColor: AppColors.danger600,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Timeline
                  _SectionTitle('Timeline Status'),
                  const SizedBox(height: 12),
                  _Timeline(peminjaman: peminjaman),

                  const SizedBox(height: 24),

                  // Items List
                  _SectionTitle('Daftar Alat'),
                  const SizedBox(height: 12),
                  ...peminjaman.items.map((item) => _ItemCard(item: item)),

                  const SizedBox(height: 32),

                  // Actions
                  if (isPetugas && peminjaman.canApprove) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showApproveDialog(peminjaman),
                            icon: Icon(Icons.check),
                            label: Text('Setujui'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success600,
                              minimumSize: Size(0, 48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showRejectDialog(peminjaman),
                            icon: Icon(Icons.close),
                            label: Text('Tolak'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger600,
                              minimumSize: Size(0, 48),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (isPetugas && peminjaman.canReturn)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FormPengembalianPage(
                                peminjamanId: peminjaman.id,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.assignment_return),
                        label: Text('Proses Pengembalian'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return Center(child: Text('Gagal memuat data'));
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return AppColors.warning500;
      case 'disetujui':
        return AppColors.info500;
      case 'sebagian':
        return AppColors.secondary500;
      case 'selesai':
        return AppColors.success500;
      case 'ditolak':
        return AppColors.danger500;
      default:
        return AppColors.neutral500;
    }
  }

  void _showApproveDialog(Peminjaman peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Setujui Peminjaman?'),
        content: Text(
          'Setujui peminjaman ${peminjaman.peminjam?.displayNameOrEmail}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final user =
                  (context.read<AuthCubit>().state as Authenticated).user;
              context
                  .read<PeminjamanCubit>()
                  .approvePeminjaman(peminjaman.id, user.id);
            },
            child: Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Peminjaman peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tolak Peminjaman?'),
        content: Text(
          'Tolak peminjaman ${peminjaman.peminjam?.displayNameOrEmail}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final user =
                  (context.read<AuthCubit>().state as Authenticated).user;
              context
                  .read<PeminjamanCubit>()
                  .rejectPeminjaman(peminjaman.id, user.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger600,
            ),
            child: Text('Tolak'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h4,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      entry.value.icon,
                      size: 20,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.value,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: entry.value.valueColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });
}

class _Timeline extends StatelessWidget {
  final Peminjaman peminjaman;

  const _Timeline({required this.peminjaman});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        title: 'Pengajuan Dibuat',
        time: peminjaman.createdAt,
        isCompleted: true,
        isActive: peminjaman.status == 'menunggu',
      ),
      _TimelineStep(
        title: 'Persetujuan Petugas',
        time: peminjaman.disetujuiPada,
        isCompleted: peminjaman.disetujuiPada != null,
        isActive: peminjaman.status == 'disetujui' ||
            peminjaman.status == 'sebagian' ||
            peminjaman.status == 'selesai',
      ),
      _TimelineStep(
        title: 'Pengembalian',
        time: peminjaman.items.any((i) => i.status == 'dikembalikan')
            ? peminjaman.items
                .firstWhere((i) => i.status == 'dikembalikan')
                .dikembalikanPada
            : null,
        isCompleted: peminjaman.items.any((i) => i.status == 'dikembalikan'),
        isActive: peminjaman.status == 'sebagian',
      ),
      _TimelineStep(
        title: 'Selesai',
        time: peminjaman.status == 'selesai' ? peminjaman.updatedAt : null,
        isCompleted: peminjaman.status == 'selesai',
        isActive: peminjaman.status == 'selesai',
      ),
    ];

    return AppCard(
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final isLast = entry.key == steps.length - 1;
          return _TimelineItem(
            step: entry.value,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final DateTime? time;
  final bool isCompleted;
  final bool isActive;

  _TimelineStep({
    required this.title,
    this.time,
    required this.isCompleted,
    required this.isActive,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? AppColors.success500
                      : step.isActive
                          ? AppColors.primary500
                          : AppColors.neutral300,
                  shape: BoxShape.circle,
                ),
                child: step.isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : step.isActive
                        ? Icon(Icons.circle, color: Colors.white, size: 12)
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted
                        ? AppColors.success500
                        : AppColors.neutral200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: step.isActive || step.isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: step.isActive || step.isCompleted
                          ? AppColors.neutral900
                          : AppColors.neutral500,
                    ),
                  ),
                  if (step.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(step.time!),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final PeminjamanItem item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('dd MMM yyyy');

    return AppCard(
      margin: EdgeInsets.only(bottom: 12),
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
                  ],
                ),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _ItemInfo(
                  label: 'Jatuh Tempo',
                  value: dateFormat.format(item.jatuhTempo),
                  isDanger: item.isTerlambat && item.status == 'dipinjam',
                ),
              ),
              if (item.dikembalikanPada != null)
                Expanded(
                  child: _ItemInfo(
                    label: 'Dikembalikan',
                    value: dateFormat.format(item.dikembalikanPada!),
                  ),
                ),
            ],
          ),
          if (item.terlambatHari != null && item.terlambatHari! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: AppColors.danger500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Terlambat ${item.terlambatHari} hari',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.danger700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Denda: Rp ${currencyFormat.format(item.totalDenda)}',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.danger700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool isDanger;

  const _ItemInfo({
    required this.label,
    required this.value,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.neutral500,
          ),
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
}