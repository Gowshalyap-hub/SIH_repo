class LabRecord {
  final String id;
  final String cowId;
  final DateTime timestamp;
  final double somaticCellCount; // SCC
  final double phLevel;
  final String pathogenResults;

  LabRecord({
    required this.id,
    required this.cowId,
    required this.timestamp,
    required this.somaticCellCount,
    required this.phLevel,
    required this.pathogenResults,
  });
}
