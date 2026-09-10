import '../../models/smart_cup.dart';
import '../../models/milking_session.dart';
import '../../models/milk_reading.dart';

class MockSmartCupService {
  Future<SmartCup> getSmartCupStatus(String smartCupId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return SmartCup(id: smartCupId, macAddress: 'AA:BB:CC:DD:EE:FF', isOnline: true);
  }

  Future<MilkingSession> startMilkingSession(String cowId, String smartCupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MilkingSession(
      id: 'sess_101',
      cowId: cowId,
      smartCupId: smartCupId,
      startTime: DateTime.now(),
    );
  }

  Future<MilkReading> endMilkingSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MilkReading(
      id: 'mr_101',
      sessionId: sessionId,
      timestamp: DateTime.now(),
      yieldLiters: 12.5,
      electricalConductivity: 4.2,
      milkTemperature: 35.8,
      colourData: 'Normal',
    );
  }
}
