import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../models/risk_level.dart';
import '../../services/api/api_alert_service.dart';

class AlertProvider extends ChangeNotifier {
  final ApiAlertService _alertService = ApiAlertService();

  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _error;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addAlertLocal(Alert alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  Future<void> loadAlerts(String farmId) async {
    // _isLoading = true;
    _error = null;
    notifyListeners();

    if (_alerts.isNotEmpty) return; // PROTOTYPE
    _alerts = [
      Alert(
        id: 'A001',
        cowId: '05555',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        message: 'Moderate risk identified. Monitor milk yield.',
        severity: RiskLevel.moderate,
      )
    ];
    notifyListeners();
    return;
    try {
      _alerts = await _alertService.getActiveAlerts(farmId);
    } catch (e) {
      _error = 'Failed to load alerts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String alertId) {
    // Modify alert locally for now
    notifyListeners();
  }
}
