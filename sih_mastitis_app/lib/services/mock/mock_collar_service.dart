import '../../models/collar_device.dart';
import '../../models/collar_reading.dart';

class MockCollarService {
  Future<CollarDevice> getCollarDetails(String collarId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CollarDevice(id: collarId, macAddress: '00:11:22:33:44:55', isOnline: true, batteryLevel: 85);
  }

  Future<CollarReading> getLatestReading(String collarId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CollarReading(
      id: 'cr_001',
      collarId: collarId,
      timestamp: DateTime.now(),
      bodyTemperature: 39.2,
      activityLevel: 65.0,
      ruminationMinutes: 420.0,
    );
  }
}
