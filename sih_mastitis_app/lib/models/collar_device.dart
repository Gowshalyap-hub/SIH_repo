class CollarDevice {
  final String id;
  final String macAddress;
  final bool isOnline;
  final int batteryLevel;

  CollarDevice({required this.id, required this.macAddress, this.isOnline = true, this.batteryLevel = 100});
}
