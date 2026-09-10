import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/alert.dart';
import '../../models/risk_level.dart';

class ApiAlertService {
  Future<List<Alert>> getActiveAlerts(String farmId) async {
    return getAlerts();
  }
  Future<List<Alert>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/alerts'), headers: ApiConfig.headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map<Alert>((e) => Alert(
          id: e['id'],
          message: e['message'],
          timestamp: DateTime.parse(e['timestamp']),
          severity: e['severity'] == 'high' ? RiskLevel.high : (e['severity'] == 'moderate' ? RiskLevel.moderate : RiskLevel.low),
          isRead: e['read'] ?? false,
          cowId: e['cowId'],
        )).toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }
}
