import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/smart_milk_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';

class SmartMilkLiveScreen extends StatelessWidget {
  const SmartMilkLiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartMilkProvider>();
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('smart_milk___step_3'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('live_milk_data') ?? 'Live Milk Data', style: AppTextStyles.h2, textAlign: TextAlign.center),
            Text('Session: ${provider.currentSession?.id ?? "--"}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _LiveCard('Milk Yield', 'Live L', Icons.water_drop),
                  _LiveCard('Milk EC', 'Live mS/cm', Icons.bolt),
                  _LiveCard('Milk Temp', 'Live °C', Icons.thermostat),
                  _LiveCard('pH', 'Live pH', Icons.science),
                  _LiveCard('Colour', 'Live Spec', Icons.color_lens),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).translate('note__wokwi_simulation_does_no') ?? 'Note: Wokwi simulation does not provide EC data. EC will be unavailable.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            AppButton(text: AppLocalizations.of(context).translate('stop___review'),
              onPressed: () async {
                await provider.step3StopLiveData();
                if (context.mounted) context.push('/smart-milk/review');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _LiveCard(String title, String placeholder, IconData icon) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppColors.riskNone),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
