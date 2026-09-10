class SmartCup {
  final String id;
  final String macAddress;
  final bool isOnline;
  final int batteryLevel;

  SmartCup({required this.id, required this.macAddress, this.isOnline = true, this.batteryLevel = 100});
}
