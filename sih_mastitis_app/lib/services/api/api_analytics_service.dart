import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiAnalyticsService {
  Future<Map<String, dynamic>> getFinancialOverview(String farmId) async { return {}; }
  Future<Map<String, dynamic>> getAnalytics(String farmId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      String url = '${ApiConfig.baseUrl}/analytics/farm/$farmId';
      List<String> queryParams = [];
      if (startDate != null) {
        queryParams.add('start_date=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        queryParams.add('end_date=${endDate.toIso8601String()}');
      }
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      final response = await http.get(Uri.parse(url), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    }
    return {
      "risk_distribution": {"High Risk": 0, "Moderate Risk": 0, "Low Risk": 0},
      "milk_averages": []
    };
  }
}
