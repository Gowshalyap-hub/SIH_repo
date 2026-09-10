class MilkingSession {
  final String id;
  final String cowId;
  final String smartCupId;
  final DateTime startTime;
  final DateTime? endTime;

  MilkingSession({
    required this.id,
    required this.cowId,
    required this.smartCupId,
    required this.startTime,
    this.endTime,
  });
}
