import '../../models/ai_prediction.dart';
import '../../models/risk_level.dart';

class MockAIService {
  Future<AIPrediction> getLatestPrediction(String cowId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Return different predictions based on mock cow ID to demonstrate UI states
    if (cowId == 'COW-024') {
      return AIPrediction(
        id: 'pred_024',
        cowId: cowId,
        timestamp: DateTime.now(),
        predictionType: 'Mastitis Risk',
        modelName: 'xgboost_v2',
        predictedClass: 'High',
        mastitisProbability: 0.85,
        featuresUsed: ['Milk EC', 'Rumination Drop', 'Body Temperature'],
        warning: 'High Risk Detected',
      );
    } else if (cowId == 'COW-025') {
       return AIPrediction(
        id: 'pred_025',
        cowId: cowId,
        timestamp: DateTime.now(),
        predictionType: 'Mastitis Risk',
        modelName: 'xgboost_v2',
        predictedClass: 'Moderate',
        mastitisProbability: 0.60,
        featuresUsed: ['Activity Drop', 'Milk Yield Drop'],
        warning: 'Moderate Risk',
      );
    }
    
    return AIPrediction(
      id: 'pred_default',
      cowId: cowId,
      timestamp: DateTime.now(),
      predictionType: 'Mastitis Risk',
      modelName: 'xgboost_v2',
      predictedClass: 'Low',
      mastitisProbability: 0.10,
      featuresUsed: [],
      warning: 'Low Risk',
    );
  }
}
