import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/risk_level.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  
  const RiskBadge({Key? key, required this.risk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (risk) {
      case RiskLevel.high:
        bgColor = AppColors.riskHighBg;
        textColor = AppColors.riskHigh;
        text = 'High';
        break;
      case RiskLevel.moderate:
        bgColor = AppColors.riskModerateBg;
        textColor = AppColors.riskModerate;
        text = 'Moderate';
        break;
      case RiskLevel.low:
        bgColor = AppColors.riskLowBg;
        textColor = AppColors.riskLow;
        text = 'Low';
        break;
      case RiskLevel.none:
        bgColor = AppColors.riskNoneBg;
        textColor = AppColors.riskNone;
        text = 'No Risk';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

