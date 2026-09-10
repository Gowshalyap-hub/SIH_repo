import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/cow.dart';

import '../../models/risk_level.dart';

class ApiCowService {
  Future<List<Cow>> getCows(String farmId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/farms/$farmId/cows'), headers: ApiConfig.headers).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) {
          RiskLevel risk = RiskLevel.none;
          if (e['current_risk_level'] == 'high') risk = RiskLevel.high;
          else if (e['current_risk_level'] == 'moderate') risk = RiskLevel.moderate;
          else if (e['current_risk_level'] == 'low') risk = RiskLevel.low;
          
          return Cow(
            id: e['id']?.toString() ?? '',
            farmId: e['farm_id']?.toString() ?? farmId,
            rfid: e['rfid']?.toString() ?? '',
            tagNumber: e['id']?.toString() ?? '',
            dateOfBirth: e['dob'] != null ? DateTime.tryParse(e['dob']) ?? DateTime.now() : DateTime.now(),
            breed: e['breed']?.toString() ?? '',
            currentRiskLevel: risk,
            lastMilkYield: e['last_milk_yield'] != null ? (e['last_milk_yield'] as num).toDouble() : null,
            lastUpdated: e['last_updated'] != null ? DateTime.tryParse(e['last_updated']) : null,
            assignedCollarId: e['collar_id']?.toString(),
          );
        }).toList();
      } else {
        throw Exception('Failed to load cows: ${response.statusCode}');
      }
    } catch (e) {
      print('getCows error: $e');
      rethrow;
    }
  }

  Future<Cow> createCow(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cows'),
        headers: ApiConfig.headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 8));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final e = jsonDecode(response.body);
        return Cow(
          id: e['id']?.toString() ?? data['id'],
          farmId: e['farm_id']?.toString() ?? '',
          rfid: e['rfid']?.toString() ?? '',
          tagNumber: e['id']?.toString() ?? data['id'],
          dateOfBirth: e['dob'] != null ? DateTime.tryParse(e['dob']) ?? DateTime.now() : DateTime.now(),
          breed: e['breed']?.toString() ?? '',
          currentRiskLevel: RiskLevel.none,
        );
      }
      throw Exception('Failed to create cow: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('createCow error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCowHistory(String cowId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/history'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>?> getLatestPrediction(String cowId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/prediction/latest'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
