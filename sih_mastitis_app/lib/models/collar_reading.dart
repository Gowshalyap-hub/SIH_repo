class CollarReading {
  final String id;
  final String collarId;
  final DateTime timestamp;
  final double bodyTemperature; // DS18B20
  final double activityLevel; // MPU6050
  final double? accelerationMagnitude;
  final double ruminationMinutes; // INMP441
  final double? ruminationSoundLevel;
  final double? humidity; // DHT22

  CollarReading({
    required this.id,
    required this.collarId,
    required this.timestamp,
    required this.bodyTemperature,
    required this.activityLevel,
    this.accelerationMagnitude,
    required this.ruminationMinutes,
    this.ruminationSoundLevel,
    this.humidity,
  });
}
