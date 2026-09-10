import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/alert_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../models/risk_level.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AlertProvider>().loadAlerts('farm_001'));
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('alerts')), 
        backgroundColor: AppColors.surface, 
        foregroundColor: AppColors.textPrimary, 
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: alertProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : alertProvider.alerts.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context).translate('no_alerts_at_this_time_') ?? 'No alerts at this time.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: alertProvider.alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alertProvider.alerts[index];
                          return _buildAlertCard(context, alert);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _FilterChip(label: AppLocalizations.of(context).translate('all') ?? 'All', isSelected: true, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: AppLocalizations.of(context).translate('high') ?? 'High', isSelected: false, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: AppLocalizations.of(context).translate('moderate') ?? 'Moderate', isSelected: false, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: AppLocalizations.of(context).translate('low') ?? 'Low', isSelected: false, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, alert) {
    Color riskColor = AppColors.riskLow;
    String riskText = 'Low Risk';
    if (alert.severity == RiskLevel.high) {
      riskColor = AppColors.riskHigh;
      riskText = 'High Risk';
    } else if (alert.severity == RiskLevel.moderate) {
      riskColor = AppColors.riskModerate;
      riskText = 'Moderate Risk';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: InkWell(
          onTap: () => context.push('/cow/${alert.cowId}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cow ${alert.cowId}', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(riskText, style: AppTextStyles.bodySmall.copyWith(color: riskColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(alert.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text('${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2,"0")}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
