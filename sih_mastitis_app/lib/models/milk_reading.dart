class MilkReading {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final double yieldLiters; // Load Cell
  final double electricalConductivity; // EC Meter
  final double milkTemperature; // DS18B20
  final String colourData; // AS7341 spectral data

  MilkReading({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.yieldLiters,
    required this.electricalConductivity,
    required this.milkTemperature,
    required this.colourData,
  });
}
