import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_card.dart';
import '../../../providers/herd_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api/api_manual_data_service.dart';
import '../../../providers/cow_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../models/alert.dart';
import '../../../models/risk_level.dart';

class ManualDataScreen extends StatefulWidget {
  const ManualDataScreen({Key? key}) : super(key: key);

  @override
  State<ManualDataScreen> createState() => _ManualDataScreenState();
}

class _ManualDataScreenState extends State<ManualDataScreen> {
  String? selectedCowId;
  final bodyTempController = TextEditingController();
  final udderTempController = TextEditingController();
  final milkCondController = TextEditingController();
  final activityController = TextEditingController();
  final notesController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final farmId = authProvider.currentUser?.farmId ?? 'owner_id';
      context.read<HerdProvider>().loadHerd(farmId);
    });
  }

  Future<void> _submitData() async {
    if (selectedCowId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('please_select_a_cow'))));
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final farmId = authProvider.currentUser?.farmId ?? 'owner_id';
    
    // PROTOTYPE MODE: Immediately update local state in both providers
    final cowProvider = context.read<CowProvider>();
    final herdProvider = context.read<HerdProvider>();
    
    try {
      final selectedCow = herdProvider.allCows.firstWhere((c) => c.id == selectedCowId);
      cowProvider.selectCow(selectedCow);
    } catch (_) {}

    cowProvider.addManualReadingLocal(
      bodyTemp: double.tryParse(bodyTempController.text),
      udderTemp: double.tryParse(udderTempController.text),
      milkCond: double.tryParse(milkCondController.text),
      activityLevel: double.tryParse(activityController.text),
      milkYield: null,
      notes: notesController.text,
    );
    
    if (cowProvider.selectedCow != null) {
      herdProvider.updateCowLocal(cowProvider.selectedCow!);
      
      if (cowProvider.selectedCow!.currentRiskLevel == RiskLevel.high) {
        final alertProvider = context.read<AlertProvider>();
        alertProvider.addAlertLocal(Alert(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          cowId: cowProvider.selectedCow!.id,
          timestamp: DateTime.now(),
          message: cowProvider.latestPrediction?.warning ?? 'High risk identified from manual sensor reading.',
          severity: RiskLevel.high,
        ));
      }
    }
    
    // Fire-and-forget background sync
    final service = ApiManualDataService();
    service.submitSensorReading(
      cowId: selectedCowId!,
      bodyTemp: double.tryParse(bodyTempController.text),
      udderTemp: double.tryParse(udderTempController.text),
      milkCond: double.tryParse(milkCondController.text),
      activity: double.tryParse(activityController.text),
    ).catchError((_) {});

    context.read<HerdProvider>().loadHerd(farmId).catchError((_) {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate('saved_successfully_'))));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final herdProvider = context.watch<HerdProvider>();
    final cows = herdProvider.allCows;
    
    if (cows.isNotEmpty && selectedCowId == null) {
      selectedCowId = cows.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('log_sensor_reading')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: herdProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context).translate('all_values_are_used_to_calcula') ?? 'All values are used to calculate risk.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            
            AppCard(
              child: DropdownButtonHideUnderline(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButton<String>(
                    value: selectedCowId,
                    isExpanded: true,
                    hint: Text(AppLocalizations.of(context).translate('select_a_cow')),
                    items: cows.map((cow) => DropdownMenuItem(
                      value: cow.id,
                      child: Text(cow.id, style: AppTextStyles.h3),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCowId = val;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // LIVE RISK SCORE
            _buildLiveRiskBadge(),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: AppTextField(
                  label: AppLocalizations.of(context).translate('body_temp___c_') ?? 'Body Temp (°C)', 
                  controller: bodyTempController, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState((){}),
                )),
                const SizedBox(width: 16),
                Expanded(child: AppTextField(
                  label: AppLocalizations.of(context).translate('udder_temp___c_') ?? 'Udder Temp (°C)', 
                  controller: udderTempController, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState((){}),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppTextField(
                  label: AppLocalizations.of(context).translate('milk_conductivity__ms_cm_') ?? 'Milk Conductivity (mS/cm)', 
                  controller: milkCondController, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState((){}),
                )),
                const SizedBox(width: 16),
                Expanded(child: AppTextField(
                  label: AppLocalizations.of(context).translate('activity_level') ?? 'Activity Level', 
                  controller: activityController, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState((){}),
                )),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: AppLocalizations.of(context).translate('note__optional_') ?? 'Note (optional)', 
              hintText: AppLocalizations.of(context).translate('add_observation___') ?? 'Add observation...',
              maxLines: 3,
              controller: notesController,
            ),
            
            const SizedBox(height: 32),
            isSubmitting 
              ? const Center(child: CircularProgressIndicator())
              : AppButton(text: AppLocalizations.of(context).translate('save_reading'), onPressed: _submitData),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRiskBadge() {
    double? bodyTemp = double.tryParse(bodyTempController.text);
    double? milkCond = double.tryParse(milkCondController.text);
    
    // Quick Risk calculation to mirror CowProvider's logic
    RiskLevel liveRisk = RiskLevel.low;
    String riskText = 'Low Risk';
    Color riskColor = AppColors.riskLow;

    if ((bodyTemp != null && bodyTemp > 39.5) || (milkCond != null && milkCond > 5.5)) {
      liveRisk = RiskLevel.high;
      riskText = 'High Risk';
      riskColor = AppColors.riskHigh;
    } else if ((bodyTemp != null && bodyTemp > 39.0) || (milkCond != null && milkCond > 5.0)) {
      liveRisk = RiskLevel.moderate;
      riskText = 'Moderate Risk';
      riskColor = AppColors.riskModerate;
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Risk Score', style: AppTextStyles.h3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor, width: 1),
              ),
              child: Text(
                riskText,
                style: AppTextStyles.bodySmall.copyWith(color: riskColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
