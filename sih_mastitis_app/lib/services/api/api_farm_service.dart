import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/farm.dart';
import '../../models/cow.dart';

class ApiFarmService {
  Future<Farm> getFarmData(String ownerId) async {
    try {
      final farms = await getFarms();
      if (farms.isNotEmpty) {
        return farms.first;
      }
    } catch (e) {
      print(e);
    }
    return Farm(id: '1', name: 'Main Farm', location: 'Unknown', ownerId: ownerId);
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/dashboard'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load dashboard data');
  }

  Future<List<Cow>> getCows(String farmId) async {
    return [];
  }
  Future<List<Farm>> getFarms() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/farms'), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Farm.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<Farm> updateFarm(Farm farm) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/farms/${farm.id}'),
      headers: ApiConfig.headers,
      body: jsonEncode(farm.toJson()),
    );
    if (response.statusCode == 200) {
      return Farm.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update farm');
  }
}
