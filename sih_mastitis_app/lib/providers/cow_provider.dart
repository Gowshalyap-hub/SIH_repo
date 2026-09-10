import 'package:flutter/material.dart';
import '../../models/cow.dart';
import '../../models/risk_level.dart';
import '../../models/manual_reading.dart';
import '../../models/collar_reading.dart';
import '../../models/ai_prediction.dart';
import '../../services/api/api_collar_service.dart';
import '../../services/api/api_ai_service.dart';
import '../../services/api/api_cow_service.dart';

class CowProvider extends ChangeNotifier {
  final ApiCollarService _collarService = ApiCollarService();
  final ApiAIService _aiService = ApiAIService();

  Cow? _selectedCow;
  CollarReading? _latestReading;
  AIPrediction? _latestPrediction;
  bool _isLoading = false;
  String? _error;

  Cow? get selectedCow => _selectedCow;
  CollarReading? get latestReading => _latestReading;
  AIPrediction? get latestPrediction => _latestPrediction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectCow(Cow cow) {
    _selectedCow = cow;
    notifyListeners();
  }

  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => _history;

  void addManualReadingLocal({
    required double? bodyTemp,
    required double? udderTemp,
    required double? milkCond,
    required double? activityLevel,
    required double? milkYield,
    required String? notes,
  }) {
    if (_selectedCow == null) return;

    // 1. Prototype Risk Logic
    double prob = 0.1;
    String warning = 'Normal readings.';
    RiskLevel newRisk = RiskLevel.low;

    if ((bodyTemp != null && bodyTemp > 39.5) || (milkCond != null && milkCond > 5.5)) {
      prob = 0.85;
      newRisk = RiskLevel.high;
      warning = 'Elevated temperature/conductivity detected.';
    } else if ((bodyTemp != null && bodyTemp > 39.0) || (milkCond != null && milkCond > 5.0)) {
      prob = 0.45;
      newRisk = RiskLevel.moderate;
      warning = 'Slightly elevated readings.';
    }

    _latestPrediction = AIPrediction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cowId: _selectedCow!.id,
      mastitisProbability: prob,
      timestamp: DateTime.now(),
      predictionType: 'Mastitis Risk',
      modelName: 'Prototype Fallback Model',
      predictedClass: newRisk == RiskLevel.high ? 2 : (newRisk == RiskLevel.moderate ? 1 : 0),
      featuresUsed: ['bodyTemp: $bodyTemp', 'milkCond: $milkCond'],
      warning: warning,
    );

    // 2. Create ManualReading
    final newReading = ManualReading(
      cowId: _selectedCow!.id,
      timestamp: DateTime.now(),
      bodyTemperature: bodyTemp,
      milkTemperature: udderTemp,
      milkConductivity: milkCond,
      activityLevel: activityLevel,
      notes: notes,
      riskScore: prob,
      riskLevel: newRisk,
    );

    // 3. Update Cow in memory
    final updatedReadings = List<ManualReading>.from(_selectedCow!.manualReadings)..insert(0, newReading);

    _selectedCow = _selectedCow!.copyWith(
      currentRiskLevel: newRisk,
      lastMilkYield: milkYield ?? _selectedCow!.lastMilkYield,
      lastUpdated: DateTime.now(),
      notes: notes ?? _selectedCow!.notes,
      manualReadings: updatedReadings,
      latestRisk: prob,
    );
    
    // Add to legacy _history just in case it's used elsewhere
    _history.insert(0, {
      'type': milkYield != null ? 'Milk Reading' : 'Manual Entry',
      'timestamp': DateTime.now().toIso8601String(),
      'yield': milkYield,
      'temp': bodyTemp ?? udderTemp,
      'ec': milkCond,
      'notes': notes ?? '',
    });
    
    notifyListeners();
  }

  double calculateLiveRisk({
    double? bodyTemp,
    double? milkCond,
  }) {
    double prob = 0.1;
    if ((bodyTemp != null && bodyTemp > 39.5) || (milkCond != null && milkCond > 5.5)) {
      prob = 0.85;
    } else if ((bodyTemp != null && bodyTemp > 39.0) || (milkCond != null && milkCond > 5.0)) {
      prob = 0.45;
    }
    return prob;
  }


  Future<void> loadCowData(String collarId) async {
    // _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestReading = await _collarService.getLatestReading(collarId);
      if (_selectedCow != null) {
        _latestPrediction = await _aiService.getLatestPrediction(_selectedCow!.id);
        
        final cowService = ApiCowService();
        _history = await cowService.getCowHistory(_selectedCow!.id);
      }
    } catch (e) {
      _error = 'Failed to load cow data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
