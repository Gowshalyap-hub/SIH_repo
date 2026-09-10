import 'package:flutter/material.dart';
import '../../services/api/api_analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiAnalyticsService _service = ApiAnalyticsService();

  Map<String, dynamic>? _financialOverview;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = false;
  String? _error;

  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, dynamic>? get financialOverview => _financialOverview;
  Map<String, dynamic>? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  Future<void> fetchAnalyticsData(String farmId, {DateTime? startDate, DateTime? endDate}) async {
    // _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analyticsData = await _service.getAnalytics(farmId, startDate: startDate ?? _startDate, endDate: endDate ?? _endDate);
    } catch (e) {
      _error = 'Failed to load analytics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
