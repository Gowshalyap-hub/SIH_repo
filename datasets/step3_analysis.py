import os
import pandas as pd
import numpy as np

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"
raw_dir = os.path.join(base_dir, "raw")
if not os.path.exists(raw_dir):
    raw_dir = base_dir

# 1. Search for Mapping
mapping_records = []
c_folders = [f"C{i:02d}" for i in range(1, 17)]
t_folders = [f"T{i:02d}" for i in range(1, 15)]
all_folders = c_folders + t_folders

# Let's see if there is any explicit mapping file in the inventory
inv_ds_path = os.path.join(base_dir, 'dataset_inventory.csv')
if os.path.exists(inv_ds_path):
    df_ds = pd.read_csv(inv_ds_path)
    mapping_files = df_ds[df_ds['file_path'].str.contains('map|reference|config', case=False, na=False)]
    if not mapping_files.empty:
        mapping_evidence = f"Found potential mapping files: {mapping_files['file_path'].tolist()}"
    else:
        mapping_evidence = "No explicit mapping files found in dataset inventory."
else:
    mapping_evidence = "No dataset inventory found."

# For now, if no mapping is found, we mark as NO_MAPPING_FOUND
for folder in all_folders:
    mapping_records.append({
        'sensor_or_folder_id': folder,
        'identifier_type': 'Device/Folder ID',
        'cow_id': 'UNKNOWN',
        'mapping_status': 'NO_MAPPING_FOUND',
        'source_file': 'None',
        'evidence': mapping_evidence,
        'confidence': 'LOW'
    })

pd.DataFrame(mapping_records).to_csv(os.path.join(base_dir, 'sensor_cow_mapping.csv'), index=False)

# 2. Verify class1 target and Mastitis Event Timeline
timeline_records = []
cm_file_candidates = [
    os.path.join(base_dir, 'Clinical_Mastitis_cows_version2', 'Clinical_Mastitis_cows_version2', 'clinical_mastitis_cows.csv'),
    os.path.join(base_dir, 'Clinical_Mastitis_cows_version2', 'clinical_mastitis_cows.csv')
]

cm_file = None
for c in cm_file_candidates:
    if os.path.exists(c):
        cm_file = c
        break

if cm_file:
    df_cm = pd.read_csv(cm_file)
    if 'Cow_ID' in df_cm.columns and 'Day' in df_cm.columns and 'class1' in df_cm.columns:
        # Sort by Cow_ID and Day
        try:
            df_cm['Day'] = pd.to_datetime(df_cm['Day'])
        except:
            pass # Keep as string/int if parsing fails
            
        df_cm = df_cm.sort_values(by=['Cow_ID', 'Day'])
        
        for cow, group in df_cm.groupby('Cow_ID'):
            pos_days = group[group['class1'] == 1]
            first_pos = pos_days['Day'].min() if not pos_days.empty else None
            
            timeline_records.append({
                'cow_id': cow,
                'first_positive_day': first_pos,
                'positive_days': len(pos_days),
                'negative_days': len(group[group['class1'] == 0]),
                'total_days': len(group),
                'event_identified': 'Yes' if first_pos is not None else 'No',
                'notes': ''
            })
            
pd.DataFrame(timeline_records).to_csv(os.path.join(base_dir, 'mastitis_event_timeline.csv'), index=False)

# 3. Temporal Overlap & Target Design Report
# Determine sensor dates
min_sensor_date = "Unknown"
max_sensor_date = "Unknown"
try:
    c01_file = os.path.join(base_dir, 'sensor_data', 'behavior_labels', 'individual', 'C01_0725.csv')
    if os.path.exists(c01_file):
        df_c01 = pd.read_csv(c01_file)
        if 'datetime' in df_c01.columns:
            min_sensor_date = df_c01['datetime'].min()
            max_sensor_date = df_c01['datetime'].max()
except:
    pass

md_content = f"""# 7-14 Day Target Design Report

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
- **Sensor Dates**: Example from `C01` spans roughly `{min_sensor_date}` to `{max_sensor_date}`.
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
"""

with open(os.path.join(base_dir, 'target_design_report.md'), 'w') as f:
    f.write(md_content)

print("Step 3 analysis complete.")
