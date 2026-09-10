import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_button.dart';
import '../../../providers/cow_provider.dart';
import '../../../providers/herd_provider.dart';
import '../../../models/cow.dart';
import '../../../models/risk_level.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/api/api_config.dart';

class CowProfileScreen extends StatefulWidget {
  final String cowId;
  final Cow? cow;
  
  const CowProfileScreen({Key? key, required this.cowId, this.cow}) : super(key: key);

  @override
  State<CowProfileScreen> createState() => _CowProfileScreenState();
}

class _CowProfileScreenState extends State<CowProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      final cp = context.read<CowProvider>();
      if (widget.cow != null) {
        cp.selectCow(widget.cow!);
      }
      cp.loadCowData(widget.cow?.assignedCollarId ?? 'C-000');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final herdProvider = context.watch<HerdProvider>();
    // Single source of truth: pull the cow directly from the herd list by ID.
    // If not found (e.g. deep link without load), fallback to widget.cow.
    Cow? cow;
    try {
      cow = herdProvider.allCows.firstWhere((c) => c.id == widget.cowId);
    } catch (_) {
      cow = widget.cow;
    }

    final cowProvider = context.watch<CowProvider>();
    final reading = cowProvider.latestReading;

    if (cow == null) return Scaffold(appBar: AppBar(title: Text(widget.cowId)), body: const Center(child: Text('Cow not found locally. Please sync.')));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('cow_details')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(cow),
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Health'),
                Tab(text: 'History'),
                Tab(text: 'AI Risk'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(cow, reading),
                Center(child: Text(AppLocalizations.of(context).translate('health_data') ?? 'Health Data')),
                _buildHistoryTab(cow),
                _buildAiRiskTab(cow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Cow cow) {
    Color riskColor = AppColors.riskNone;
    String riskText = 'Healthy';
    if (cow.currentRiskLevel == RiskLevel.high) {
      riskColor = AppColors.riskHigh;
      riskText = 'High Risk';
    } else if (cow.currentRiskLevel == RiskLevel.moderate) {
      riskColor = AppColors.riskModerate;
      riskText = 'Moderate Risk';
    } else if (cow.currentRiskLevel == RiskLevel.low) {
      riskColor = AppColors.riskLow;
      riskText = 'Low Risk';
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  image: cow.photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(cow.photoPath!)) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: cow.photoPath == null ? const Icon(Icons.pets, size: 40, color: AppColors.primary) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cow.id, style: AppTextStyles.h1),
                    Text(cow.breed, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(riskText, style: AppTextStyles.bodySmall.copyWith(color: riskColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem('Age', '${DateTime.now().year - cow.dateOfBirth.year} yrs'), 
              _StatItem('Lactation', '${cow.lactationNumber ?? 1}'),
              _StatItem('Daily Milk', cow.lastMilkYield != null ? '${cow.lastMilkYield!.toStringAsFixed(1)} L' : '-- L'), 
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Cow cow, reading) {
    double riskScore = cow.latestRisk ?? 0.0;
    if (riskScore == 0.0) {
      if (cow.currentRiskLevel == RiskLevel.high) riskScore = 0.8;
      else if (cow.currentRiskLevel == RiskLevel.moderate) riskScore = 0.5;
      else riskScore = 0.1;
    }
    
    String milkText = '-- L';
    if (cow.lastMilkYield != null) milkText = '${cow.lastMilkYield!.toStringAsFixed(1)} L';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).translate('risk_score') ?? 'Risk Score', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: riskScore,
                          strokeWidth: 8,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(riskScore > 0.7 ? AppColors.riskHigh : (riskScore > 0.4 ? AppColors.riskModerate : AppColors.riskLow)),
                        ),
                        Center(child: Text('${(riskScore * 100).toInt()}%', style: AppTextStyles.h2.copyWith(color: riskScore > 0.7 ? AppColors.riskHigh : (riskScore > 0.4 ? AppColors.riskModerate : AppColors.riskLow)))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(riskScore > 0.7 ? 'High Risk' : (riskScore > 0.4 ? 'Moderate Risk' : 'Low Risk'), style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text('Updated ${cow.lastUpdated != null ? _formatTimeDiff(cow.lastUpdated!) : '--'}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                    ],
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
                      children: [
                        Text(AppLocalizations.of(context).translate('milk_today') ?? 'Milk Today', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(milkText, style: AppTextStyles.h2),
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
                      children: [
                        Text(AppLocalizations.of(context).translate('last_7_days_avg') ?? 'Last 7 Days Avg', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context).translate('___l') ?? '-- L', style: AppTextStyles.h2), // Keep simple for now or calculate from history
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(text: AppLocalizations.of(context).translate('log_sensor_reading'),
            onPressed: () => context.push('/manual-data'),
          ),
        ],
      ),
    );
  }
  
  String _formatTimeDiff(DateTime time) {
      final diff = DateTime.now().difference(time);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
  }

  Future<List<dynamic>> _fetchHistory(String cowId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/history'),
      headers: ApiConfig.headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load history');
    }
  }

  Widget _buildHistoryTab(Cow cow) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchHistory(cow.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading history: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context).translate('no_historical_data_available') ?? 'No history available'));
        }

        final history = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final type = item['type'] ?? 'Unknown';
            final timestampStr = item['timestamp'];
            final time = timestampStr != null ? DateTime.parse(timestampStr).toLocal() : DateTime.now();
            
            String subtitle = '';
            IconData icon = Icons.history;
            Color iconColor = AppColors.primary;
            
            if (type == 'Live Data') {
              final riskLevel = item['risk_level'] ?? 'UNKNOWN';
              subtitle = 'Risk: $riskLevel';
              if (item['temp'] != null && item['temp'] > 0) subtitle += ' | Temp: ${item['temp']}°C';
              if (item['cond'] != null && item['cond'] > 0) subtitle += ' | EC: ${item['cond']}';
              if (item['yield'] != null && item['yield'] > 0) subtitle += ' | Yield: ${item['yield']}L';
              icon = Icons.online_prediction;
              if (riskLevel == 'HIGH') iconColor = AppColors.riskHigh;
              else if (riskLevel == 'MODERATE') iconColor = AppColors.riskModerate;
              else if (riskLevel == 'LOW') iconColor = AppColors.riskLow;
            } else if (type == 'Milk Reading') {
              if (item['yield'] != null) subtitle += 'Yield: ${item['yield']}L';
              if (item['ec'] != null) subtitle += ' | EC: ${item['ec']}';
              if (item['temp'] != null) subtitle += ' | Temp: ${item['temp']}°C';
              icon = Icons.water_drop;
              iconColor = AppColors.primary;
            } else {
              if (item['notes'] != null) subtitle = 'Notes: ${item['notes']}';
              icon = Icons.sensor_door;
            }

            return AppCard(
               child: ListTile(
                 leading: Icon(icon, color: iconColor),
                 title: Text(type, style: AppTextStyles.h3),
                 subtitle: Text(subtitle),
                 trailing: Text('${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}', style: AppTextStyles.bodySmall),
               ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildAiRiskTab(Cow cow) {
    double riskScore = cow.latestRisk ?? 0.0;
    if (riskScore == 0.0) {
      if (cow.currentRiskLevel == RiskLevel.high) riskScore = 0.8;
      else if (cow.currentRiskLevel == RiskLevel.moderate) riskScore = 0.5;
      else riskScore = 0.1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).translate('current_risk_assessment') ?? 'Current Risk Assessment', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          AppCard(
             child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model: MastiQ-v3-Local', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Probability: ${(riskScore * 100).toStringAsFixed(1)}%', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    if (riskScore > 0.4)
                       Container(
                         padding: const EdgeInsets.all(8),
                         color: AppColors.riskHigh.withValues(alpha: 0.1),
                         child: Text('WARNING: Elevated mastitis probability.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.riskHigh)),
                       ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context).translate('features_analysed_') ?? 'Features Analysed:', style: AppTextStyles.h3),
                    Text('• Body Temperature\n• Milk Conductivity\n• Activity Level\n• Milk Yield'),
                    const SizedBox(height: 16),
                    AppButton(text: AppLocalizations.of(context).translate('view_prediction_logs'),
                      onPressed: () => context.push('/prediction/${cow.id}'),
                    ),
                  ],
                ),
             ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3),
      ],
    );
  }
}
