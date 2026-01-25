// lib/presentation/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const AppCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}