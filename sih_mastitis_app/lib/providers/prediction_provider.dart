import 'package:flutter/material.dart';
import '../../models/ai_prediction.dart';
import '../../services/api/api_ai_service.dart';

class PredictionProvider extends ChangeNotifier {
  final ApiAIService _aiService = ApiAIService();

  AIPrediction? _currentPrediction;
  bool _isLoading = false;
  String? _error;

  AIPrediction? get currentPrediction => _currentPrediction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPrediction(String cowId, double temp, double ec, double yieldLiters) async {
    // _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPrediction = await _aiService.getPrediction(cowId, temp, ec, yieldLiters);
    } catch (e) {
      _currentPrediction = null; // Don't keep stale data
      _error = 'failed_to_load_prediction';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
