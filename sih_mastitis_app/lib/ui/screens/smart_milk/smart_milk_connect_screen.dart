import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/smart_milk_provider.dart';
import '../../../widgets/app_button.dart';

class SmartMilkConnectScreen extends StatelessWidget {
  const SmartMilkConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmartMilkProvider>();
    
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('smart_milk___step_2'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi, size: 100, color: AppColors.riskNone),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context).translate('connect_shared_smart_cup') ?? 'Connect Shared Smart Cup', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('For ${provider.selectedCow?.id ?? "Cow"}', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).translate('the_smart_cup_is_a_shared_sess') ?? 'The Smart Cup is a SHARED session device. It is temporarily linked to this cow for the duration of this milking session.', textAlign: TextAlign.center),
              const SizedBox(height: 48),
              AppButton(text: AppLocalizations.of(context).translate('connect_smart_cup'),
                onPressed: () async {
                  await provider.step2ConnectCup('CUP-001');
                  if (context.mounted) context.push('/smart-milk/live');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
