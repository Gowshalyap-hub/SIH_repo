class Feedback {
  final String id;
  final String userId; // Farmer/Veterinarian
  final String predictionId;
  final DateTime timestamp;
  final bool isAccurate;
  final String comments;

  Feedback({
    required this.id,
    required this.userId,
    required this.predictionId,
    required this.timestamp,
    required this.isAccurate,
    required this.comments,
  });
}
