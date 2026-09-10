class MockRecommendationService {
  Future<List<String>> getRecommendations(String cowId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      'Isolate COW-024 for monitoring.',
      'Check udder health and milk appearance manually.',
      'Consult veterinarian immediately.'
    ];
  }
}
