import 'risk_level.dart';

class ManualReading {
  final String cowId;
  final DateTime timestamp;
  final double? bodyTemperature;
  final double? milkTemperature;
  final double? milkConductivity;
  final double? activityLevel;
  final String? notes;
  final double riskScore;
  final RiskLevel riskLevel;

  ManualReading({
    required this.cowId,
    required this.timestamp,
    this.bodyTemperature,
    this.milkTemperature,
    this.milkConductivity,
    this.activityLevel,
    this.notes,
    required this.riskScore,
    required this.riskLevel,
  });
}
