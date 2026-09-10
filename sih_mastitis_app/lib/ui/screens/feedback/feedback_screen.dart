import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('clinical_feedback')), backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('provide_ground_truth_feedback_') ?? 'Provide ground truth feedback. Verified feedback contributes to future ML model improvement.', style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'Checked', child: Text(AppLocalizations.of(context).translate('checked'))),
                DropdownMenuItem(value: 'Suspected', child: Text(AppLocalizations.of(context).translate('suspected'))),
                DropdownMenuItem(value: 'Confirmed', child: Text(AppLocalizations.of(context).translate('confirmed'))),
                DropdownMenuItem(value: 'Not Confirmed', child: Text(AppLocalizations.of(context).translate('not_confirmed'))),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('clinical_observations') ?? 'Clinical Observations'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('treatment_provided__if_any_') ?? 'Treatment Provided (if any)'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('outcome_notes') ?? 'Outcome/Notes'),
            const SizedBox(height: 32),
            AppButton(text: AppLocalizations.of(context).translate('submit_feedback'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('feedback_submitted_for_model_improvement_'))));
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
