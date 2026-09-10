class MockDashboardService {
  Future<Map<String, dynamic>> getDashboardSummary(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'totalCattle': 28,
      'healthyCattle': 15,
      'riskSummary': {
        'noRisk': 15,
        'lowRisk': 5,
        'moderateRisk': 4,
        'highRisk': 4,
      },
    };
  }
}
