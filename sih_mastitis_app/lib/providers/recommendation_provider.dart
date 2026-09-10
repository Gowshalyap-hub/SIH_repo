import 'package:flutter/material.dart';
import '../../services/api/api_recommendation_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final ApiRecommendationService _service = ApiRecommendationService();

  List<String> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<String> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecommendations(String cowId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _service.getRecommendations(cowId);
    } catch (e) {
      _error = 'Failed to load recommendations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
