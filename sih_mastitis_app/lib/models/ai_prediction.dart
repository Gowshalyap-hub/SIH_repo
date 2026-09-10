class AIPrediction {
  final String id;
  final String cowId;
  final DateTime timestamp;
  final String predictionType;
  final int predictedClass;
  final double mastitisProbability;
  final String modelName;
  final List<String> featuresUsed;
  final String warning;

  AIPrediction({
    required this.id,
    required this.cowId,
    required this.timestamp,
    required this.predictionType,
    required this.predictedClass,
    required this.mastitisProbability,
    required this.modelName,
    required this.featuresUsed,
    required this.warning,
  });
}
