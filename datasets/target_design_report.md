# 7-14 Day Target Design Report

## 1. Verified Sensor-to-Cow Mapping
- **Status**: UNRESOLVED
- **Details**: No explicit mapping file (e.g., `Device -> Cow_ID`) was found connecting the `C01`-`C16` and `T01`-`T14` folders to the `Cow_ID` present in the `clinical_mastitis_cows.csv` file. 
- **Impact**: Without this mapping, sensor features cannot be securely tied to clinical labels.

## 2. Unresolved Mappings
- `C01`-`C16` and `T01`-`T14` cannot be assumed to equal `Cow_ID` 1-16.

## 3. Verified Meaning of `class1`
- **Source**: `clinical_mastitis_cows.csv`
- **Values**: 0 and 1.
- **Meaning**: Represents a daily binary indicator of mastitis. Based on the dataset name, 1 = Mastitis Present, 0 = Normal/Absent.

## 4. Mastitis Event Definition
- **Definition**: The "onset" event is defined as the *first* day a cow transitions to `class1 == 1`. 
- **Data Support**: See `mastitis_event_timeline.csv` for exact first positive days.

## 5. Temporal Coverage
- **Clinical Dates**: Need to aggregate Day range from `clinical_mastitis_cows.csv`.
- **Sensor Dates**: Example from `C01` spans roughly `0:00:00` to `9:59:59`.
- **Overlap**: Cannot be verified at the cow-level until the device-cow mapping is resolved.

## 6. 7-14 Day Target Definition
For a given observation on Day $D$:
- **Target = 1**: If the *first* positive `class1` event for that cow occurs between Day $D+7$ and Day $D+14$.
- **Target = 0**: If no positive event occurs in that window.

## 7. Number of Usable Cows/Events
- **Status**: 0 usable cows currently.
- **Reason**: Although `mastitis_event_timeline.csv` identifies events for clinical cows, we cannot attach the sensor history to them due to the missing `Sensor->Cow` mapping.

## 8. Leakage Risks
- **Current-day `class1`**: High leakage risk if used as a feature. Must be dropped during forecasting.
- **Concurrent SCC/pH**: If recorded on the day of `class1 == 1`, they leak the outcome.
- **Post-event data**: Any data recorded on or after the `first_positive_day` must not be used to predict that specific onset event.

## 9. Forecasting Support Status
**CONDITIONALLY SUPPORTED**
- **Evidence**: The clinical dataset provides a clear timeline of events (`Day`, `class1`), and the sensor dataset provides rich pre-event telemetry. 
- **Condition**: Forecasting is strictly blocked until the `Device_ID` (e.g., C01) to `Cow_ID` mapping is resolved. Without this, we cannot temporally align historical sensor behavior with the future mastitis event.

## 10. Exact Evidence/Files Used
- `datasets/dataset_inventory.csv`
- `datasets/Clinical_Mastitis_cows_version2/clinical_mastitis_cows.csv`
- Sampled `datasets/sensor_data/behavior_labels/individual/C01_0725.csv`
