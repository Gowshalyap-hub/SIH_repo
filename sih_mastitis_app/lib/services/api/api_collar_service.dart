import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/collar_device.dart';

import '../../models/collar_reading.dart';

class ApiCollarService {
  Future<CollarReading?> getLatestReading(String collarId) async { return null; }
  Future<CollarDevice> getCollarStatus(String collarId) async {
    return CollarDevice(id: collarId, macAddress: '00:00:00', isOnline: true);
  }
}
