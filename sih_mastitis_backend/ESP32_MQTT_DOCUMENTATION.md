# ESP32 → MQTT Data Contract Documentation

This document defines the exact hardware-to-backend data contract for the SIH Mastitis prediction system. It is meant for the embedded/IoT engineers programming the physical ESP32.

## 1. MQTT Broker Configuration
- **Broker Address:** `test.mosquitto.org` *(Replace with production broker IP if moving off test)*
- **Port:** `1883`
- **Topic:** `sih/mastitis/cow/data`

## 2. Expected JSON Payload
The ESP32 must publish a JSON string containing exactly the following keys:
- `cow_id` (String): The unique identifier of the cow (e.g. `"COW-001"`)
- `temp` (Float): Milk/Udder temperature in Celsius
- `cond` (Float): Milk electrical conductivity
- `yield` (Float): Milk yield in liters

> [!WARNING]
> Do not use `temperature`, `conductivity`, or `milk_yield`. You must use the exact short keys: `temp`, `cond`, `yield` to match the existing schema.

### Example ESP32 Publish Message
```json
{
  "cow_id": "COW-001",
  "temp": 38.5,
  "cond": 4.2,
  "yield": 12.5
}
```

### Example Simulated Message (from `mqtt_test_publisher.py`)
```json
{
  "cow_id": "COW-HIGH",
  "temp": 39.0,
  "cond": 7.5,
  "yield": 6.0
}
```

## 3. Backend Validation Rules
The FastAPI backend (`app/iot/mqtt.py`) strictly enforces this contract.
- The payload must be valid parseable JSON.
- ALL four keys (`cow_id`, `temp`, `cond`, `yield`) must be present. Missing any key will result in the payload being dropped.
- Sensor values (`temp`, `cond`, `yield`) must be valid floating-point numbers. Non-numeric values will be rejected.
- The backend accepts messages from any physical ESP32 device publishing to the topic; there is no hardcoded hardware MAC address restriction.

## 4. Full Pipeline Flow
1. **ESP32** publishes the JSON payload to `sih/mastitis/cow/data`.
2. **FastAPI backend** receives, parses, and validates the data.
3. **Mastitis Risk Equation** is calculated, generating a probability score (0-100) and risk level (LOW/MODERATE/HIGH).
4. **Database** permanently stores this calculation as a new `AIPrediction` record for the cow, logging the exact timestamp.
5. **Flutter App** dynamically pulls this history and displays it cleanly on the Live Data/History tab for the specific cow.
