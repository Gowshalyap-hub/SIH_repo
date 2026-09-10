import 'package:flutter/material.dart';
import 'app_card.dart';
import '../app/theme/app_text_styles.dart';
import '../app/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  const KpiCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(color: valueColor ?? AppColors.textPrimary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.caption),
          ]
        ],
      ),
    );
  }
}
