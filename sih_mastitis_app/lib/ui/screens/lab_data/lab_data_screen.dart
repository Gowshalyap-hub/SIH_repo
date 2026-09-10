import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class LabDataScreen extends StatelessWidget {
  const LabDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('add_lab_data'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('laboratory_measurements_are_en') ?? 'Laboratory measurements are entered manually and are not currently measured by the live Smart Cup IoT.', style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            AppTextField(label: AppLocalizations.of(context).translate('somatic_cell_count__scc_') ?? 'Somatic Cell Count (SCC)'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('ph_level') ?? 'pH Level'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('pathogen_culture_result') ?? 'Pathogen Culture Result'),
            const SizedBox(height: 32),
            AppButton(text: AppLocalizations.of(context).translate('save_lab_data'), onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
