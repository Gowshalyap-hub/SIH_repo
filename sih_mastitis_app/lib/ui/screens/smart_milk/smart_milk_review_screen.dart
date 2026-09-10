import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/smart_milk_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';

class SmartMilkReviewScreen extends StatelessWidget {
  const SmartMilkReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartMilkProvider>();
    final reading = provider.liveReading;
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('smart_milk___step_4'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('review_session') ?? 'Review Session', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _row('Cow ID', provider.selectedCow?.id ?? '--'),
                  _row('Smart Cup (Shared)', provider.connectedCup?.id ?? '--'),
                  const Divider(),
                  _row('Milk Yield', '${reading?.yieldLiters ?? "--"} L'),
                  _row('pH', '--'),
                  _row('Milk EC', '${reading?.electricalConductivity ?? "--"} mS/cm'),
                  _row('Milk Temp', '${reading?.milkTemperature ?? "--"} °C'),
                  _row('Colour', reading?.colourData ?? '--'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(text: AppLocalizations.of(context).translate('save_session___update_prediction'),
              onPressed: () async {
                await provider.step4SaveSession();
                   
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('session_saved__wokwi_simulation_does_not_provide_required_ec_input__skipping_ml_prediction_'))));
                   context.go('/dashboard');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
