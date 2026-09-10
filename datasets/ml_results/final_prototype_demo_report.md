# Final Prototype Demo Report
**Project:** SIH Bovine Mastitis Mobile Application
**Status:** Completed End-to-End Integration

## 1. System Architecture

The prototype uses a distributed architecture designed for real-time and fallback IoT telemetry ingestion, Machine Learning evaluation, and dynamic mobile interfaces. 

### Data Flow
1. **IoT Hardware (Wokwi Simulation):**
   - **Sampling Cup**: ESP32, RFID RC522 (Cow Identification), DS18B20 (Milk Temp), pH Sensor, HX711 (Milk Yield), AS7341 (Spectral Data), WiFi.
   - **Collar**: ESP32, MPU6050 (Activity/Acceleration), INMP441 (Rumination Sound Level), DS18B20 (Body Temp), DHT22 (Humidity), WiFi.
2. **Ingestion Layer:**
   - Primary: MQTT via HiveMQ
   - Fallback: HTTP via FastAPI (`/api/v1/iot/wokwi-fallback`)
3. **Backend Processing (FastAPI):**
   - Routes telemetry into appropriate DB schemas (`MilkReading`, `CollarReading`, `TemperatureReading`, `LabRecord`).
   - Ensures decoupling between live ML inference features and passive analytical features.
4. **Machine Learning Model:**
   - Triggers synchronously when Sampling Cup submits ML-ready inputs (Milk Temperature, Milk Conductivity, Milk Yield).
   - Generates predictions (0 = Normal, 1 = Mastitis Present).
5. **Mobile Application (Flutter):**
   - Fetches evaluated readings and displays real-time health data via UI components dynamically.
   - Supports multilinguality (English, Tamil, Hindi).

## 2. Testing and Validation

- **E2E Backend Test:** Verified via `pytest tests/test_e2e_wokwi.py`, confirming resilient data routing for both Collar and Sampling Cup workflows.
- **Data Segregation:** Successfully sequestered pH and Spectral parameters out of the live ML pathway. pH is stored explicitly in `LabRecord` for later laboratory audits.
- **Flutter Client Tests:** Passed structural widget tests (`flutter test`) and codebase linter (`flutter analyze`).

## 3. Limitations and Constraints
- **ML Capabilities:** The current ML model (`mastitis_current_state_baseline.pkl`) evaluates current-state mastitis purely on cross-sectional data. **It is NOT a 7-14 day forecasting model**. The dataset exhibited deterministic separation which is artificially strong.
- **Microphone:** The supplied Wokwi Collar simulation does not contain INMP441 audio metrics. The backend handles this by leaving `rumination_sound_level` null. The Flutter UI explicitly notes "Not available in current simulation".
- **Electrical Conductivity (EC):** The Wokwi Sampling Cup does not simulate EC. Therefore, the Flutter Smart Milk flow gracefully skips live ML prediction when saved, displaying a warning instead of submitting fabricated EC data to the strict baseline model.
- **pH Data Segregation:** pH readings are received from the Wokwi analog simulation but are explicitly segregated into `LabRecord` entities and are excluded from the live predictive ML features, enforcing our previously defined data constraint boundaries.

## 4. End-to-End Demo Steps
1. Navigate to **Smart Milk / Milking** in the Flutter app.
2. In the Wokwi simulation, "scan" an RFID tag to trigger ESP32-1.
3. ESP32-1 detects RFID, maps to Cow ID, dynamically starts a new `MilkingSession` in the FastAPI backend, and publishes a `START` trigger to ESP32-2.
4. ESP32-2 (Collar) wakes, bundles activity/rumination/body temp data, and publishes to the broker.
5. The FastAPI MQTT client intercepts the raw string payloads, parses the `|` delimited data for the collar and the newline delimited data for the cup, and ingests them into SQLite schemas (`MilkReading`, `CollarReading`, `LabRecord`).
6. Flutter automatically refreshes the UI dynamically based on the backend data.

## 5. Conclusion
The pipeline satisfies the final mentor demonstration criteria. We have successfully built the End-to-End pathway (Wokwi -> API/MQTT -> DB/ML -> Flutter App) without compromising structural integrity or inventing fabricated ML metrics.
