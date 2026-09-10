import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/api/api_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import 'package:provider/provider.dart';
import '../../../providers/cow_provider.dart';

class LivePredictionScreen extends StatefulWidget {
  const LivePredictionScreen({Key? key}) : super(key: key);

  @override
  State<LivePredictionScreen> createState() => _LivePredictionScreenState();
}

class _LivePredictionScreenState extends State<LivePredictionScreen> {
  Timer? _timer;
  Map<String, dynamic>? _latestData;
  bool _isWaiting = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final cowProvider = context.read<CowProvider>();
      final cowId = cowProvider.selectedCow?.id;
      
      if (cowId == null) {
          setState(() {
            _error = 'No cow selected. Please select a cow from the herd first.';
            _isWaiting = false;
          });
          return;
      }

      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/prediction/latest'), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'waiting') {
          setState(() {
            _isWaiting = true;
            _error = '';
          });
        } else {
          setState(() {
            _isWaiting = false;
            _latestData = data;
            _error = '';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _isWaiting = true;
          _error = 'No live data available for $cowId';
        });
      } else {
        setState(() {
          _error = 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Prediction'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isWaiting && _error.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('WAITING FOR SENSOR DATA', style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error, style: AppTextStyles.h3.copyWith(color: AppColors.riskHigh), textAlign: TextAlign.center),
        ),
      );
    }

    if (_latestData == null) {
      return const SizedBox.shrink();
    }

    final cowId = _latestData!['cow_id'] ?? 'Unknown';
    final temp = _latestData!['temp']?.toString() ?? '0.0';
    final cond = _latestData!['cond']?.toString() ?? '0.0';
    final yieldL = _latestData!['yield']?.toString() ?? '0.0';
    final riskScore = (_latestData!['risk_score'] as num?)?.toDouble() ?? 0.0;
    final riskLevel = _latestData!['risk_level'] ?? 'UNKNOWN';
    final timestampStr = _latestData!['timestamp'] ?? DateTime.now().toIso8601String();
    
    final timestamp = DateTime.parse(timestampStr);
    final diff = DateTime.now().toUtc().difference(timestamp).inSeconds;

    Color riskColor = AppColors.riskLow;
    if (riskLevel == 'HIGH') riskColor = AppColors.riskHigh;
    if (riskLevel == 'MODERATE') riskColor = AppColors.riskModerate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Text(
                  'LIVE — Last updated: $diff seconds ago',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cow Info
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
                  Text(cowId, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text('Sensor Connected', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  riskLevel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: riskColor,
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
              width: 140,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: riskScore / 100.0,
                    strokeWidth: 14,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(riskScore.toStringAsFixed(1), style: AppTextStyles.h1.copyWith(fontSize: 36)),
                        Text('Score', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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
              riskLevel,
              style: AppTextStyles.h2.copyWith(color: riskColor),
            ),
          ),
          const SizedBox(height: 32),

          // Sensor Values
          Text('Live Sensor Data', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSensorRow('Temperature', '$temp °C', Icons.thermostat),
                  const Divider(height: 24),
                  _buildSensorRow('Conductivity', cond, Icons.electrical_services),
                  const Divider(height: 24),
                  _buildSensorRow('Milk Yield', '$yieldL L', Icons.water_drop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(value, style: AppTextStyles.h3),
      ],
    );
  }
}
