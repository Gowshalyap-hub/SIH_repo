import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';

import 'package:provider/provider.dart';
import '../../../providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AnalyticsProvider>().fetchAnalyticsData('farm_001'));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final data = provider.analyticsData;
    
    // Fallback if data is null or still loading
    final riskDist = data != null ? data['risk_distribution'] : {"High Risk": 0, "Moderate Risk": 0, "Low Risk": 0};
    final List milkAverages = data != null ? data['milk_averages'] : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('reports___insights')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () async {
              final currentStart = context.read<AnalyticsProvider>().startDate ?? DateTime.now().subtract(const Duration(days: 7));
              final currentEnd = context.read<AnalyticsProvider>().endDate ?? DateTime.now();
              
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(start: currentStart, end: currentEnd),
              );
              
              if (picked != null) {
                if (!mounted) return;
                context.read<AnalyticsProvider>().setDateRange(picked.start, picked.end);
                context.read<AnalyticsProvider>().fetchAnalyticsData('farm_001');
              }
            },
          ),
        ],
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : provider.error != null 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).translate('unable_to_load_reports') ?? 'Unable to load reports', style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Retry',
                      onPressed: () => context.read<AnalyticsProvider>().fetchAnalyticsData('farm_001'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).translate('overview') ?? 'Overview', style: AppTextStyles.h2),
                Row(
                  children: [
                    Text(
                      provider.startDate != null && provider.endDate != null 
                          ? '${provider.startDate!.day}/${provider.startDate!.month} - ${provider.endDate!.day}/${provider.endDate!.month}'
                          : AppLocalizations.of(context).translate('last_7_days') ?? 'Last 7 Days', 
                      style: AppTextStyles.bodyMedium
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate('herd_health_trend') ?? 'Herd Health Trend', style: AppTextStyles.h3),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 100,
                      child: milkAverages.isEmpty 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ChartBar(0.4, 'Mon'),
                              _ChartBar(0.6, 'Tue'),
                              _ChartBar(0.5, 'Wed'),
                              _ChartBar(0.8, 'Thu'),
                              _ChartBar(0.7, 'Fri'),
                              _ChartBar(0.9, 'Sat'),
                              _ChartBar(0.6, 'Sun'),
                            ],
                          )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: milkAverages.map<Widget>((m) {
                            // simple normalization assuming max is ~20
                            double heightFactor = (m['avg'] as num) / 20.0;
                            return _ChartBar(heightFactor, m['day']);
                          }).toList(),
                        ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate('risk_distribution') ?? 'Risk Distribution', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final high = riskDist['High Risk'] ?? 0;
                        final mod = riskDist['Moderate Risk'] ?? 0;
                        final low = riskDist['Low Risk'] ?? 0;
                        final total = high + mod + low;
                        final double highPct = total > 0 ? high / total : 0.0;
                        
                        return Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: total > 0 ? highPct : 0.75, // Static 75% fill if empty
                                strokeWidth: 12,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(total > 0 ? AppColors.riskHigh : AppColors.riskModerate),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LegendItem('High', high, AppColors.riskHigh),
                                  _LegendItem('Moderate', mod, AppColors.riskModerate),
                                  _LegendItem('Low', low, AppColors.riskLow),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).translate('milk_production__avg_') ?? 'Milk Production\n(Avg)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(data != null && data['avg_milk'] != null && data['avg_milk'] > 0 
                                  ? '${(data['avg_milk'] as num).toStringAsFixed(1)} L' 
                                  : '-- L', 
                               style: AppTextStyles.h2),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                              Text('4.5%', style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                          Text('vs last 7 days', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).translate('alerts_this_week') ?? 'Alerts This Week', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(data != null ? '${data['alerts_this_week'] ?? 0}' : '0', style: AppTextStyles.h2),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                              Text('12%', style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                          Text('vs last 7 days', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ChartBar(double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 60 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }

  Widget _LegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
          Text(count.toString(), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
