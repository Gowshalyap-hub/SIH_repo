import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../../models/ai_prediction.dart';

class ApiAIService {
  Future<AIPrediction?> getPrediction(
      String cowId, double temp, double ec, double yieldLiters) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/prediction'),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'milk_temperature': temp,
        'milk_conductivity': ec,
        'milk_yield': yieldLiters,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AIPrediction(
        id: data['id'].toString(),
        cowId: data['cow_id'],
        timestamp: DateTime.parse(data['timestamp']),
        predictionType: data['prediction_type'],
        predictedClass: data['predicted_class'],
        mastitisProbability: (data['mastitis_probability'] as num).toDouble(),
        modelName: data['model_name'],
        featuresUsed: List<String>.from(data['features_used'] ?? []),
        warning: data['warning'],
      );
    } else {
      throw Exception('Failed to load prediction: ${response.statusCode}');
    }
  }

  Future<AIPrediction?> getLatestPrediction(String cowId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cows/$cowId/prediction/latest'), headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AIPrediction(
        id: data['id'] ?? '',
        cowId: data['cow_id'] ?? '',
        timestamp: DateTime.parse(data['timestamp']),
        predictionType: data['prediction_type'] ?? '',
        predictedClass: data['predicted_class'] ?? 0,
        mastitisProbability: data['mastitis_probability']?.toDouble() ?? 0.0,
        modelName: data['model_name'] ?? '',
        featuresUsed: List<String>.from(data['features_used'] ?? []),
        warning: data['warning'] ?? '',
      );
    }
    return null;
  }
}
