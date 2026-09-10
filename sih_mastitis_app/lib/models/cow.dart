import 'risk_level.dart';
import 'manual_reading.dart';

class Cow {
  final String id;
  final String farmId;
  final String rfid;
  final String tagNumber;
  final DateTime dateOfBirth;
  final String breed;
  final RiskLevel currentRiskLevel;
  final String? assignedCollarId;
  final double? lastMilkYield;
  final DateTime? lastUpdated;
  final String? photoPath;
  final int? lactationNumber;
  final String? notes;
  final List<ManualReading> manualReadings;
  final double? latestRisk;

  Cow({
    required this.id,
    required this.farmId,
    required this.rfid,
    required this.tagNumber,
    required this.dateOfBirth,
    required this.breed,
    this.currentRiskLevel = RiskLevel.none,
    this.assignedCollarId,
    this.lastMilkYield,
    this.lastUpdated,
    this.photoPath,
    this.lactationNumber,
    this.notes,
    List<ManualReading>? manualReadings,
    this.latestRisk,
  }) : manualReadings = manualReadings ?? [];

  Cow copyWith({
    String? id,
    String? farmId,
    String? rfid,
    String? tagNumber,
    DateTime? dateOfBirth,
    String? breed,
    RiskLevel? currentRiskLevel,
    String? assignedCollarId,
    double? lastMilkYield,
    DateTime? lastUpdated,
    String? photoPath,
    int? lactationNumber,
    String? notes,
    List<ManualReading>? manualReadings,
    double? latestRisk,
  }) {
    return Cow(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      rfid: rfid ?? this.rfid,
      tagNumber: tagNumber ?? this.tagNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      breed: breed ?? this.breed,
      currentRiskLevel: currentRiskLevel ?? this.currentRiskLevel,
      assignedCollarId: assignedCollarId ?? this.assignedCollarId,
      lastMilkYield: lastMilkYield ?? this.lastMilkYield,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      photoPath: photoPath ?? this.photoPath,
      lactationNumber: lactationNumber ?? this.lactationNumber,
      notes: notes ?? this.notes,
      manualReadings: manualReadings ?? this.manualReadings,
      latestRisk: latestRisk ?? this.latestRisk,
    );
  }
}
