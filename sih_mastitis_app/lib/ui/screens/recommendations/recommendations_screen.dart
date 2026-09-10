import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('recommendations')), backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('based_on_the_ai_risk_trend__he') ?? 'Based on the AI risk trend, here are structured decision-support recommendations. These do not constitute a definitive medical diagnosis.', style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            SectionHeader(title: 'High Risk Cows'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(leading: Icon(Icons.medical_services, color: AppColors.riskHigh), title: Text(AppLocalizations.of(context).translate('veterinary_consultation_recommended'))),
                  ListTile(leading: Icon(Icons.visibility, color: AppColors.riskHigh), title: Text(AppLocalizations.of(context).translate('immediate_assessment_of_udder'))),
                  ListTile(leading: Icon(Icons.fence, color: AppColors.riskHigh), title: Text(AppLocalizations.of(context).translate('consider_appropriate_isolation_per_veterinary_guidance'))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionHeader(title: 'Moderate Risk Cows'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(leading: Icon(Icons.clean_hands, color: AppColors.riskModerate), title: Text(AppLocalizations.of(context).translate('improve_udder_hygiene'))),
                  ListTile(leading: Icon(Icons.visibility, color: AppColors.riskModerate), title: Text(AppLocalizations.of(context).translate('monitor_milk_readings_closely'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
