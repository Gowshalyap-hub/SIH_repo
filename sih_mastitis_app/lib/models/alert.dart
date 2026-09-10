import 'risk_level.dart';

class Alert {
  final String id;
  final String cowId;
  final DateTime timestamp;
  final String message;
  final RiskLevel severity;
  final bool isRead;

  Alert({
    required this.id,
    required this.cowId,
    required this.timestamp,
    required this.message,
    required this.severity,
    this.isRead = false,
  });
}
