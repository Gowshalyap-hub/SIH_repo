# Dataset Inspection Report

## Summary
- **Number of files inspected:** 2277
- **Number of datasets parsed:** 1172

## 1. Important Dataset Groups Found
- archive (7)
- archive (8)
- archive (9)
- Clinical_Mastitis_cows_version2
- individual
- C01
- C02
- C03
- C04
- C05
- C06
- C07
- C08
- C09
- C10
- cbt
- T01
- T02
- T03
- T04
- T05
- T06
- T07
- T08
- T09
- T10
- T13
- T14
- milk
- thi
- weather
- ankle_accel
- health_records
- neck_dev_temp
- C11
- C12
- C13
- C14
- C15
- C16

## 2. Possible Common Keys
- **Cow/Animal IDs:** Humidity, Cow_ID, humidity_per, anchor_id, Turbidity
- **Dates:** datetime, Date, Day
- **Timestamps:** datetime, timestamp, Time

## 3. Possible Target Columns
- class1

## 4. SCC & pH Separation (Important Rule)
- SCC and pH columns must remain separate from live telemetry. (See `column_inventory.csv` for exact locations).

## 5. Feasibility of 7-14 Day Forecasting
Based ONLY on the actual data available:
- *To be determined after deeper manual review of timestamps and event occurrences in the inventory CSVs.*
- Wait for user instruction.

## Exact Files Created
- `datasets/dataset_inspection_report.md`
- `datasets/dataset_inventory.csv`
- `datasets/column_inventory.csv`
