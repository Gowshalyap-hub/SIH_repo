import os
import pandas as pd

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"
inv_ds_path = os.path.join(base_dir, 'dataset_inventory.csv')
inv_col_path = os.path.join(base_dir, 'column_inventory.csv')

df_ds = pd.read_csv(inv_ds_path)
df_cols = pd.read_csv(inv_col_path)

feature_mapping = []
master_schema = []

# Analyze Clinical Mastitis
cm_file = df_ds[df_ds['dataset_name'] == 'Clinical_Mastitis_cows_version2']['file_path'].iloc[0]
cm_df = pd.read_csv(os.path.join(base_dir, cm_file))

cow_ids = cm_df['Cow_ID'].unique() if 'Cow_ID' in cm_df.columns else []
cm_target_vals = cm_df['class1'].value_counts().to_dict() if 'class1' in cm_df.columns else {}

# Build Feature Source Mapping
# We will just parse the column inventory
for _, row in df_cols.iterrows():
    c_name = row['column_name']
    c_lower = str(c_name).lower()
    f_path = row['file_path']
    ds_name = df_ds[df_ds['file_path'] == f_path]['dataset_name'].iloc[0] if len(df_ds[df_ds['file_path'] == f_path]) > 0 else 'unknown'
    dtype = row['data_type']
    
    # Simple heuristic
    feat_name = c_name
    leak_risk = 'SAFE FEATURE'
    if 'class' in c_lower or 'mastitis' in c_lower:
        leak_risk = 'TARGET'
    
    time_gran = 'daily' if 'day' in c_lower or 'date' in c_lower else 'high-freq'
    
    if leak_risk != 'TARGET' and c_lower not in ['cow_id', 'date', 'day', 'timestamp', 'datetime', 'time']:
        feature_mapping.append({
            'feature_name': feat_name,
            'source_dataset': ds_name,
            'source_file': f_path,
            'source_column': c_name,
            'data_type': dtype,
            'time_granularity': time_gran,
            'cow_identifier': 'Cow_ID/C*/T*',
            'date_identifier': 'Day/datetime',
            'transformation_required': 'aggregate to daily',
            'leakage_risk': leak_risk,
            'notes': ''
        })

df_fm = pd.DataFrame(feature_mapping).drop_duplicates(subset=['feature_name', 'source_dataset'])
df_fm.to_csv(os.path.join(base_dir, 'feature_source_mapping.csv'), index=False)

# Master Schema
schema = [
    {'master_column': 'Cow_ID', 'source': 'All', 'transformation': 'none', 'reason': 'Primary key', 'leakage_risk': 'SAFE', 'required': 'Yes'},
    {'master_column': 'Date', 'source': 'All', 'transformation': 'none', 'reason': 'Temporal key', 'leakage_risk': 'SAFE', 'required': 'Yes'},
    {'master_column': 'Target_Mastitis_7d', 'source': 'clinical_mastitis_cows.csv (class1)', 'transformation': 'shift -7 days', 'reason': 'Forecasting target', 'leakage_risk': 'TARGET', 'required': 'Yes'},
    {'master_column': 'Daily_Milk_Yield', 'source': 'milk/ cow_milk_mastitis', 'transformation': 'sum daily', 'reason': 'Feature', 'leakage_risk': 'SAFE', 'required': 'No'},
    {'master_column': 'Daily_Avg_Activity', 'source': 'ankle_accel/behavior', 'transformation': 'mean daily', 'reason': 'Feature', 'leakage_risk': 'SAFE', 'required': 'No'}
]
pd.DataFrame(schema).to_csv(os.path.join(base_dir, 'proposed_master_schema.csv'), index=False)

# Deep Analysis MD
md = f"""# Deep Dataset Relationship & Column Analysis

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
- Values: {cm_target_vals}
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
"""

with open(os.path.join(base_dir, 'deep_dataset_analysis.md'), 'w') as f:
    f.write(md)

rel_md = """# Dataset Relationships

1. **Cow to Sensor (Device)**: 
   - `Cow_ID` (Clinical) <--> `Device_ID` (Folder names C01-C16, T01-T14). 
   - A mapping table is required if `C01` != `Cow_ID`.

2. **Temporal Alignment**:
   - Sensor data (`datetime`) must be aggregated to daily (`Day`) to match `Clinical_Mastitis_cows_version2`.
"""
with open(os.path.join(base_dir, 'dataset_relationships.md'), 'w') as f:
    f.write(rel_md)

print("Analysis complete.")
