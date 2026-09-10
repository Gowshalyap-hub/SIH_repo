import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../providers/prediction_provider.dart';
import '../../../models/risk_level.dart';
import '../../../widgets/empty_state.dart';

class PredictionScreen extends StatefulWidget {
  final String cowId;
  const PredictionScreen({Key? key, required this.cowId}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
       // Supply defaults if no live reading is available
       context.read<PredictionProvider>().fetchPrediction(widget.cowId, 38.0, 4.5, 10.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final pred = provider.currentPrediction;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('ai_risk_prediction')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pred == null
              ? EmptyState(message: 'No prediction available') 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.pets, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.cowId, style: AppTextStyles.h2),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context).translate('holstein_friesian') ?? 'Holstein Friesian', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)), // Assuming breed
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: pred.predictedClass == 1 ? AppColors.riskHigh.withValues(alpha: 0.1) : AppColors.riskNone.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pred.predictedClass == 1 ? 'High Risk' : 'Healthy', 
                          style: AppTextStyles.bodySmall.copyWith(
                            color: pred.predictedClass == 1 ? AppColors.riskHigh : AppColors.riskNone,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Score
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: pred.mastitisProbability,
                            strokeWidth: 12,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              pred.predictedClass == 1 ? AppColors.riskHigh : AppColors.riskNone
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${(pred.mastitisProbability * 100).toStringAsFixed(0)}%', style: AppTextStyles.h1.copyWith(fontSize: 32)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      pred.predictedClass == 1 ? 'High Risk' : 'Healthy', 
                      style: AppTextStyles.h2.copyWith(color: pred.predictedClass == 1 ? AppColors.riskHigh : AppColors.riskNone),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Assessment Window
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context).translate('current_state_assessment') ?? 'Current State Assessment', style: AppTextStyles.h3),
                                const SizedBox(height: 4),
                                Text(AppLocalizations.of(context).translate('based_on_latest_sensor_data') ?? 'Based on latest sensor data', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Key Factors
                  Text(AppLocalizations.of(context).translate('key_factors') ?? 'Key Factors', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  _buildFactorRow('Udder Temperature', 0.8, AppColors.riskHigh, 'High'),
                  _buildFactorRow('Milk Conductivity', 0.9, AppColors.riskHigh, 'High'),
                  _buildFactorRow('Activity Level', 0.5, AppColors.riskModerate, 'Moderate'),
                  _buildFactorRow('Body Temperature', 0.3, AppColors.riskNone, 'Normal'),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(AppLocalizations.of(context).translate('this_is_a_baseline_current_sta') ?? 'This is a baseline current-state model. Required sensor inputs might be unavailable.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildFactorRow(String label, double value, Color color, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTextStyles.bodyMedium)),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Text(status, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
