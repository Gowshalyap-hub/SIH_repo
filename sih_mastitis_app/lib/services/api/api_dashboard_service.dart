import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiDashboardService {
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/dashboard'), headers: ApiConfig.headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return {};
  }
}
