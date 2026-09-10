import 'package:flutter/material.dart';
import '../app/theme/app_text_styles.dart';
import '../app/theme/app_colors.dart';

class AlertBanner extends StatelessWidget {
  final String message;
  final String time;
  final bool isHighRisk;

  const AlertBanner({
    Key? key,
    required this.message,
    required this.time,
    this.isHighRisk = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHighRisk ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isHighRisk ? AppColors.riskHigh : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(width: 12),
          Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
