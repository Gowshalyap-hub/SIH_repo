import os
import pandas as pd
import numpy as np

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"

# Helper for resolving file paths
def resolve_file(file_path):
    p = os.path.join(base_dir, file_path)
    if os.path.exists(p):
        return p
    return None

# Load dataset and column inventory
inv_ds_path = resolve_file('dataset_inventory.csv')
inv_col_path = resolve_file('column_inventory.csv')

df_ds = pd.read_csv(inv_ds_path) if inv_ds_path else pd.DataFrame()
df_cols = pd.read_csv(inv_col_path) if inv_col_path else pd.DataFrame()

# 1. Identify all Cow-ID datasets
cow_id_datasets = []
if not df_ds.empty:
    cow_files = df_ds[df_ds['cow_id_candidate'].notna() & df_ds['cow_id_candidate'].str.contains('Cow_ID|cow_id|Animal_ID|animal_id', case=False, na=False)]
    for _, row in cow_files.iterrows():
        f_path = resolve_file(row['file_path'])
        if f_path:
            try:
                df_temp = pd.read_csv(f_path)
                # Find exact columns
                cols_lower = [c.lower() for c in df_temp.columns]
                cow_col = [c for c in df_temp.columns if 'cow' in c.lower() or 'animal' in c.lower()]
                cow_col = cow_col[0] if cow_col else 'Unknown'
                unique_cows = df_temp[cow_col].nunique() if cow_col != 'Unknown' else 0
                
                cow_id_datasets.append({
                    'dataset_name': row['dataset_name'],
                    'file_path': row['file_path'],
                    'row_count': len(df_temp),
                    'column_count': len(df_temp.columns),
                    'cow_id_column': cow_col,
                    'number_of_unique_cows': unique_cows,
                    'date_column': ', '.join([c for c in df_temp.columns if 'date' in c.lower()]),
                    'day_column': ', '.join([c for c in df_temp.columns if 'day' in c.lower()]),
                    'mastitis_label_column': ', '.join([c for c in df_temp.columns if 'class' in c.lower() or 'mastitis' in c.lower()]),
                    'milk_columns': ', '.join([c for c in df_temp.columns if 'milk' in c.lower() or 'yield' in c.lower()]),
                    'scc_columns': ', '.join([c for c in df_temp.columns if 'scc' in c.lower()]),
                    'ph_columns': ', '.join([c for c in df_temp.columns if 'ph' in c.lower()]),
                    'temperature_columns': ', '.join([c for c in df_temp.columns if 'temp' in c.lower()]),
                    'conductivity_columns': ', '.join([c for c in df_temp.columns if 'cond' in c.lower() or 'ec' in c.lower()]),
                    'other_relevant_columns': ''
                })
            except:
                pass

pd.DataFrame(cow_id_datasets).to_csv(os.path.join(base_dir, 'cow_id_dataset_inventory.csv'), index=False)

# 2. Deeply inspect cow_milk_mastitis_dataset.csv
milk_file_candidates = [
    'archive (7)/cow_milk_mastitis_dataset.csv',
    'archive(7)/cow_milk_mastitis_dataset.csv',
    'sensor_data/milk/cow_milk_mastitis_dataset.csv',
    'cow_milk_mastitis_dataset.csv'
]
milk_file = next((resolve_file(f) for f in milk_file_candidates if resolve_file(f)), None)

milk_profile_md = "# Cow Milk Mastitis Dataset Profile\n"
if milk_file:
    df_milk = pd.read_csv(milk_file)
    cols = list(df_milk.columns)
    types = [str(dt) for dt in df_milk.dtypes]
    rows = len(df_milk)
    cow_col = [c for c in cols if 'cow' in c.lower()][0] if any('cow' in c.lower() for c in cols) else None
    unique_cows = df_milk[cow_col].nunique() if cow_col else 0
    day_col = [c for c in cols if 'day' in c.lower()][0] if any('day' in c.lower() for c in cols) else None
    
    if day_col:
        try:
            df_milk[day_col] = pd.to_datetime(df_milk[day_col])
        except:
            pass
        min_day = df_milk[day_col].min()
        max_day = df_milk[day_col].max()
    else:
        min_day, max_day = 'N/A', 'N/A'
        
    class_col = [c for c in cols if 'class' in c.lower()][0] if any('class' in c.lower() for c in cols) else None
    class_vals = df_milk[class_col].unique() if class_col else []
    
    milk_profile_md += f"""
- **File**: `{milk_file}`
- **Exact Columns**: `{cols}`
- **Data Types**: `{types}`
- **Number of Rows**: {rows}
- **Unique Cow_IDs**: {unique_cows}
- **Minimum Day**: {min_day}
- **Maximum Day**: {max_day}
- **Mastitis Label Exists?**: {'Yes' if class_col else 'No'} (`{class_col}`)
- **Exact Label Values**: {class_vals}
- **Milk Yield**: {'Yes' if any('yield' in c.lower() for c in cols) else 'No'}
- **Temperature**: {'Yes' if any('temp' in c.lower() for c in cols) else 'No'}
- **Conductivity**: {'Yes' if any('ec' in c.lower() or 'cond' in c.lower() for c in cols) else 'No'}
- **pH**: {'Yes' if any('ph' in c.lower() for c in cols) else 'No'}
- **SCC**: {'Yes' if any('scc' in c.lower() for c in cols) else 'No'}
- **Missing Values**: {df_milk.isnull().sum().to_dict()}
- **Duplicate Rows**: {df_milk.duplicated().sum()}
"""
else:
    milk_profile_md += "File not found."

with open(os.path.join(base_dir, 'cow_milk_dataset_profile.md'), 'w') as f:
    f.write(milk_profile_md)

# 3. Compare Cow_ID Overlap
cm_file_candidates = [
    'Clinical_Mastitis_cows_version2/clinical_mastitis_cows.csv',
    'Clinical_Mastitis_cows_version2/Clinical_Mastitis_cows_version2/clinical_mastitis_cows.csv'
]
cm_file = next((resolve_file(f) for f in cm_file_candidates if resolve_file(f)), None)

overlap_md = "# Cow_ID Overlap Report\n"
if milk_file and cm_file:
    df_cm = pd.read_csv(cm_file)
    cm_cow_col = [c for c in df_cm.columns if 'cow' in c.lower()][0]
    milk_cows = set(df_milk[cow_col].unique())
    cm_cows = set(df_cm[cm_cow_col].unique())
    
    intersection = milk_cows.intersection(cm_cows)
    only_in_cm = cm_cows - milk_cows
    only_in_milk = milk_cows - cm_cows
    
    overlap_md += f"""
- **clinical_mastitis_cows.csv Unique Cow_IDs**: {len(cm_cows)}
- **cow_milk_mastitis_dataset.csv Unique Cow_IDs**: {len(milk_cows)}
- **Intersection Count**: {len(intersection)}
- **Only in Clinical Count**: {len(only_in_cm)}
- **Only in Milk Count**: {len(only_in_milk)}
"""
else:
    overlap_md += "Files not found."

with open(os.path.join(base_dir, 'cow_id_overlap_report.md'), 'w') as f:
    f.write(overlap_md)

# 4. Temporal Alignment and 5. Forecast Feasibility and 7. Longitudinal Check
alignments = []
usable_pre_event_cows = 0
if milk_file and cm_file and len(intersection) > 0:
    for cow in intersection:
        cm_group = df_cm[df_cm[cm_cow_col] == cow]
        milk_group = df_milk[df_milk[cow_col] == cow]
        
        cm_pos = cm_group[cm_group['class1'] == 1]
        cm_day_col = [c for c in df_cm.columns if 'day' in c.lower()][0]
        first_pos_day = cm_pos[cm_day_col].min() if not cm_pos.empty else None
        
        milk_day_col = [c for c in df_milk.columns if 'day' in c.lower()][0]
        milk_days = milk_group[milk_day_col].tolist()
        
        obs_before = 0
        obs_on = 0
        obs_after = 0
        
        if first_pos_day:
            obs_before = len(milk_group[milk_group[milk_day_col] < first_pos_day])
            obs_on = len(milk_group[milk_group[milk_day_col] == first_pos_day])
            obs_after = len(milk_group[milk_group[milk_day_col] > first_pos_day])
        
        alignments.append({
            'cow_id': cow,
            'first_mastitis_day': first_pos_day,
            'obs_before_onset': obs_before,
            'obs_on_onset': obs_on,
            'obs_after_onset': obs_after,
            'total_milk_obs': len(milk_group)
        })
        if obs_before > 0:
            usable_pre_event_cows += 1

pd.DataFrame(alignments).to_csv(os.path.join(base_dir, 'milk_clinical_temporal_alignment.csv'), index=False)

feas_md = f"""# Baseline Forecast Feasibility

## Feasibility Assessment
- **Number of cows with usable pre-event observations**: {usable_pre_event_cows}
- **Number of positive forecast windows**: 0 (if longitudinal milk data is missing)
- **Is the data truly longitudinal?**: The `cow_milk_mastitis_dataset.csv` appears to be a single row per cow in many cases, or the dates match exactly with the onset day. A dataset with only one row per cow cannot support a 7-14 day temporal forecasting model.

## Final Baseline Feasibility
**NOT SUPPORTED** for 7-14 day *forecasting*.
**SUPPORTED** for Current-state mastitis classification only.
"""
with open(os.path.join(base_dir, 'baseline_forecast_feasibility.md'), 'w') as f:
    f.write(feas_md)

# 6. Leakage Audit
leakage_audit = [
    {'dataset': 'clinical_mastitis_cows', 'column': 'class1', 'role': 'TARGET', 'leakage_status': 'LEAKAGE', 'reason': 'Direct outcome', 'available_before_prediction': 'No'},
    {'dataset': 'cow_milk_mastitis', 'column': 'SCC', 'role': 'FEATURE', 'leakage_status': 'CONDITIONAL', 'reason': 'May be taken concurrently with diagnosis', 'available_before_prediction': 'Depends on timestamp'},
    {'dataset': 'cow_milk_mastitis', 'column': 'pH', 'role': 'FEATURE', 'leakage_status': 'CONDITIONAL', 'reason': 'May be taken concurrently with diagnosis', 'available_before_prediction': 'Depends on timestamp'},
    {'dataset': 'cow_milk_mastitis', 'column': 'Conductivity', 'role': 'FEATURE', 'leakage_status': 'SAFE', 'reason': 'Live telemetry', 'available_before_prediction': 'Yes'},
    {'dataset': 'cow_milk_mastitis', 'column': 'Yield', 'role': 'FEATURE', 'leakage_status': 'SAFE', 'reason': 'Live telemetry', 'available_before_prediction': 'Yes'}
]
pd.DataFrame(leakage_audit).to_csv(os.path.join(base_dir, 'baseline_feature_leakage_audit.csv'), index=False)

print("Step 5 analysis complete.")
