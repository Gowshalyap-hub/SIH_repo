import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/manual_data.dart';

class ApiManualDataService {
  Future<void> submitManualData(ManualData data) async {}

  Future<void> submitSensorReading({
    required String cowId,
    double? bodyTemp,
    double? udderTemp,
    double? milkTemp,
    double? milkCond,
    double? activity,
    double? milkYield,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/manual-sensor-reading'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'body_temperature': bodyTemp,
          'udder_temperature': udderTemp,
          'milk_temperature': milkTemp,
          'milk_conductivity': milkCond,
          'activity_level': activity,
          'milk_yield': milkYield,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to log sensor readings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('submitSensorReading error: $e');
      rethrow;
    }
  }
}
