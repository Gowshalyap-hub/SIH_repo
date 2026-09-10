import '../../models/manual_data.dart';

class MockManualDataService {
  Future<List<ManualData>> getManualDataHistory(String cowId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ManualData(
        id: 'md_001',
        cowId: cowId,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        vaccination: 'FMD Vaccine',
        diseaseHistory: 'None',
        feeding: 'Standard TMR',
        hygiene: 'Clean',
        housing: 'Free Stall',
        managementPractices: 'Regular Milking',
        clinicalObservations: 'Healthy',
      )
    ];
  }
}
