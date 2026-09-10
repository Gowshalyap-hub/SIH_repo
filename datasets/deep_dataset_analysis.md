# Deep Dataset Relationship & Column Analysis

## 1. Verified Dataset Groups
- `Clinical_Mastitis_cows_version2`: Contains `Cow_ID`, `Day`, `class1`, etc. (6600 rows).
- `sensor_data`: High-frequency sensor recordings. The folders `C01` to `C16` and `T01` to `T14` likely represent specific device IDs or cow IDs. 
- `archive`: Looks like subsets or previous versions (e.g. `cow_milk_mastitis_dataset.csv`).

## 2. Verified Identifiers
- `Cow_ID` (in Clinical Mastitis / Milk data)
- Directory names (`C01`, `T01`, etc.) act as implicit device/cow identifiers for the sensor data. 

## 3. Verified Temporal Fields
- `Day` / `Date` for clinical/milk data (daily granularity).
- `datetime` / `timestamp` for sensor data (minute/second granularity).

## 4. Actual Cow Mapping
Sensor data in `C*` and `T*` directories must be mapped to `Cow_ID`. If a mapping file exists (e.g., Device->Cow), it can be joined. Otherwise, `C01` might directly correspond to a Cow ID or require a look-up table.

## 5. Target Analysis
- Column: `class1` (in `clinical_mastitis_cows.csv`).
- Values: {0: 3961, 1: 2639}
- Meaning: Binary or multi-class indicator of mastitis.

## 6. Clinical Mastitis Event Timeline
The `clinical_mastitis_cows.csv` contains `Day` and `class1`, providing a reliable daily timeline of the mastitis status for each `Cow_ID`.

## 7. Sensor Feature Analysis
- **Behaviour:** `ankle_accel`
- **Temperature:** `neck_dev_temp`
- **Milk:** `milk` / `cow_milk_mastitis_dataset.csv`
- **Environment:** `thi`, `weather`
- **Location:** `uwb_distance`, `visual_location`

## 8. Duplicate / Overlapping Data
- `archive (7)/cow_milk_mastitis_dataset.csv` may overlap with `Clinical_Mastitis_cows_version2`.
- Multiple milk files need deduplication.

## 9. Data Leakage Analysis
- **Target Leakage:** Current day `class1` cannot be used to predict current day. It must be shifted 7-14 days.
- **SCC / pH:** If taken on the day of diagnosis, they are post-event/concurrent indicators and cannot be used for 7-14 day *forecasting* unless historical values are used.

## 10. Forecasting Feasibility
- **Feasible?** Yes, *if* the high-frequency sensor data (`C01`-`C16`) aligns temporally with the 7-14 days prior to a positive `class1` event in `clinical_mastitis_cows.csv`. 

## 11. Proposed Master Dataset Structure
- Grain: **ONE ROW = ONE COW × ONE DAY**
- See `proposed_master_schema.csv` for details.
