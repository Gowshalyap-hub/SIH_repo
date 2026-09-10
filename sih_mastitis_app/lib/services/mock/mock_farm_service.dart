import '../../models/farm.dart';
import '../../models/cow.dart';
import '../../models/risk_level.dart';

class MockFarmService {
  Future<Farm> getFarmData(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Farm(
      id: 'farm_001',
      name: 'Green Valley Dairy',
      location: 'Coimbatore, TN',
      ownerId: ownerId,
    );
  }

  Future<List<Cow>> getCows(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Cow(id: 'COW-001', farmId: farmId, rfid: 'RFID_BF3A7C9001', tagNumber: 'T001', dateOfBirth: DateTime(2021, 5, 10), breed: 'Holstein', currentRiskLevel: RiskLevel.none, assignedCollarId: 'COL-001'),
      Cow(id: 'COW-002', farmId: farmId, rfid: 'RFID_BF3A7C9002', tagNumber: 'T002', dateOfBirth: DateTime(2022, 1, 15), breed: 'Jersey', currentRiskLevel: RiskLevel.low, assignedCollarId: 'COL-002'),
      Cow(id: 'COW-025', farmId: farmId, rfid: 'RFID_BF3A7C9025', tagNumber: 'T025', dateOfBirth: DateTime(2020, 11, 20), breed: 'Holstein', currentRiskLevel: RiskLevel.moderate, assignedCollarId: 'COL-025'),
      Cow(id: 'COW-024', farmId: farmId, rfid: 'RFID_BF3A7C9024', tagNumber: 'T024', dateOfBirth: DateTime(2019, 8, 5), breed: 'Holstein', currentRiskLevel: RiskLevel.high, assignedCollarId: 'COL-024'),
    ];
  }
}
