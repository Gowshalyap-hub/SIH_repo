import '../../models/alert.dart';
import '../../models/risk_level.dart';

class MockAlertService {
  Future<List<Alert>> getActiveAlerts(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      Alert(id: 'alt_1', cowId: 'COW-024', timestamp: DateTime.now().subtract(const Duration(minutes: 30)), message: 'High risk detected in COW-024. 2 Days prediction.', severity: RiskLevel.high),
      Alert(id: 'alt_2', cowId: 'COW-017', timestamp: DateTime.now().subtract(const Duration(hours: 1)), message: 'EC level high in COW-017', severity: RiskLevel.high),
      Alert(id: 'alt_3', cowId: 'COW-009', timestamp: DateTime.now().subtract(const Duration(hours: 2)), message: 'Rumination drop in COW-009', severity: RiskLevel.moderate),
    ];
  }
}
