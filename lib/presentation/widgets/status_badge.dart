// lib/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusBadge({
    Key? key,
    required this.status,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getStatusBgColor(status);
    final textColor = AppColors.getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getDisplayStatus(status),
        style: TextStyle(
          color: textColor,
          fontSize: isLarge ? 12 : 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return 'Tersedia';
      case 'tidak_tersedia':
        return 'Tidak tersedia';
      case 'dipinjam':
        return 'Dipinjam';
      case 'nonaktif':
        return 'Nonaktif';
      case 'menunggu':
        return 'Menunggu';
      case 'disetujui':
        return 'Disetujui';
      case 'sebagian':
        return 'Sebagian';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'dikembalikan':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}