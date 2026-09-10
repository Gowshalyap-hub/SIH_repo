import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/smart_cup.dart';
import '../../models/milking_session.dart';
import '../../models/milk_reading.dart';

class ApiSmartCupService {
  Future<SmartCup?> getSmartCupStatus(String cupId) async { return await connectToCup(cupId); }
  Future<SmartCup?> connectToCup(String cupId) async {
    return SmartCup(id: cupId, macAddress: '00:11:22', isOnline: true, batteryLevel: 100);
  }

  Future<MilkingSession> startMilkingSession(String cowId, String cupId) async {
    return MilkingSession(id: 'sess_1', cowId: cowId, startTime: DateTime.now(), smartCupId: cupId);
  }

  Future<MilkReading> getLiveReading(String sessionId) async {
    return MilkReading(
      id: 'read_1',
      sessionId: sessionId,
      timestamp: DateTime.now(),
      yieldLiters: 1200.5,
      electricalConductivity: 4.5,
      milkTemperature: 38.6,
      colourData: "{'red': 100, 'green': 100, 'blue': 100}",
    );
  }

  Future<MilkReading?> endMilkingSession(String sessionId) async { return null; }
}
