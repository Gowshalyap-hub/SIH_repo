import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/herd_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../models/cow.dart';
import '../../../models/milk_reading.dart';

class SmartMilkRfidScreen extends StatefulWidget {
  const SmartMilkRfidScreen({Key? key}) : super(key: key);

  @override
  State<SmartMilkRfidScreen> createState() => _SmartMilkRfidScreenState();
}

class _SmartMilkRfidScreenState extends State<SmartMilkRfidScreen> {
  String? _selectedCowId;
  final TextEditingController _yieldController = TextEditingController();

  @override
  void dispose() {
    _yieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final herdProvider = context.watch<HerdProvider>();
    final cows = herdProvider.allCows;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('smart_milk') ?? 'Smart Milk (Manual)')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).translate('select_cow') ?? 'Select Cow', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCowId,
                items: cows.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.tagNumber} - ${c.breed}'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCowId = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select a cow'),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context).translate('milk_yield__l_') ?? 'Milk Yield (Liters)', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              TextField(
                controller: _yieldController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. 10.5'),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: AppLocalizations.of(context).translate('save_reading') ?? 'Save Reading',
                onPressed: () {
                  if (_selectedCowId == null || _yieldController.text.trim().isEmpty) return;
                  final yieldVal = double.tryParse(_yieldController.text.trim());
                  if (yieldVal == null) return;

                  final reading = MilkReading(
                    id: DateTime.now().toIso8601String(),
                    sessionId: DateTime.now().toIso8601String(),
                    timestamp: DateTime.now(),
                    yieldLiters: yieldVal,
                    electricalConductivity: 4.5, // Dummy default
                    milkTemperature: 38.0, // Dummy default
                    colourData: 'Normal', // Dummy default
                  );

                  herdProvider.addMilkReading(_selectedCowId!, reading);
                  
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context).translate('milk_saved') ?? 'Milk Reading Saved!'),
                  ));
                  
                  context.go('/dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
