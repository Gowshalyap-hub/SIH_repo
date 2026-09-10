class MockAnalyticsService {
  Future<Map<String, dynamic>> getFinancialOverview(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      'expensesIncurred': 3250.0,
      'potentialSaved': 6780.0,
      'weeklyProduction': 350.6,
      'productionChange': 8.5,
    };
  }
}
