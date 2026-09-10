import '../../models/lab_record.dart';

class MockLabService {
  Future<List<LabRecord>> getLabRecords(String cowId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      LabRecord(
        id: 'lab_001',
        cowId: cowId,
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        somaticCellCount: 150000.0,
        phLevel: 6.6,
        pathogenResults: 'Negative',
      )
    ];
  }
}
