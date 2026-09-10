import os
import pandas as pd
import json
import numpy as np

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"
target_dir = os.path.join(base_dir, "raw")
if not os.path.exists(target_dir):
    target_dir = base_dir

excluded_dirs = ["cleaned", "master", "ml_ready", ".venv"]

dataset_inventory = []
column_inventory = []

def get_file_type(filepath):
    ext = filepath.split('.')[-1].lower()
    return ext

def classify_column(col_name):
    col_lower = str(col_name).lower()
    if any(kw in col_lower for kw in ['id', 'uuid', 'mac', 'address']):
        return 'IDENTIFIER'
    elif any(kw in col_lower for kw in ['mastitis', 'disease', 'diagnosis', 'label', 'target', 'class']):
        return 'TARGET candidate'
    elif any(kw in col_lower for kw in ['scc', 'ph', 'ec', 'temp', 'yield', 'activity', 'rumination', 'milk', 'blood', 'colour']):
        return 'KEEP candidate'
    elif any(kw in col_lower for kw in ['date', 'time', 'day', 'timestamp']):
        return 'KEEP candidate' 
    else:
        return 'UNKNOWN / NEEDS REVIEW'

def determine_granularity(df):
    time_cols = [col for col in df.columns if any(kw in str(col).lower() for kw in ['date', 'time', 'timestamp'])]
    if not time_cols:
        return "unknown"
    return "unknown (needs manual review)"

print(f"Starting inspection in: {target_dir}")
file_count = 0
dataset_count = 0

for root, dirs, files in os.walk(target_dir):
    dirs[:] = [d for d in dirs if d not in excluded_dirs]
    for file in files:
        file_count += 1
        ext = get_file_type(file)
        if ext not in ['csv', 'xlsx', 'xls']:
            continue
            
        filepath = os.path.join(root, file)
        rel_path = os.path.relpath(filepath, base_dir)
        dataset_name = os.path.basename(root)
        print(f"Processing: {rel_path}")
        
        try:
            if ext == 'csv':
                df = pd.read_csv(filepath, nrows=5000)
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    total_rows = sum(1 for _ in f) - 1 
            elif ext in ['xlsx', 'xls']:
                df = pd.read_excel(filepath, nrows=5000)
                df_full = pd.read_excel(filepath)
                total_rows = len(df_full)
            else:
                continue
                
            dataset_count += 1
            num_cols = len(df.columns)
            
            cow_id_candidate = ", ".join([str(c) for c in df.columns if 'cow' in str(c).lower() or 'animal' in str(c).lower() or ('id' in str(c).lower() and 'device' not in str(c).lower())])
            date_candidate = ", ".join([str(c) for c in df.columns if 'date' in str(c).lower() or 'day' in str(c).lower()])
            timestamp_candidate = ", ".join([str(c) for c in df.columns if 'time' in str(c).lower()])
            target_candidate = ", ".join([str(c) for c in df.columns if 'mastitis' in str(c).lower() or 'target' in str(c).lower() or 'label' in str(c).lower() or 'class' in str(c).lower()])
            
            granularity = determine_granularity(df)
            
            dataset_inventory.append({
                'file_path': rel_path,
                'dataset_name': dataset_name,
                'file_type': ext,
                'rows': total_rows,
                'columns': num_cols,
                'cow_id_candidate': cow_id_candidate,
                'date_candidate': date_candidate,
                'timestamp_candidate': timestamp_candidate,
                'target_candidate': target_candidate,
                'time_granularity': granularity,
                'notes': ''
            })
            
            for col in df.columns:
                missing_pct = df[col].isnull().mean() * 100 if len(df) > 0 else 0
                unique_cnt = df[col].nunique()
                sample_val = str(df[col].dropna().iloc[0]) if not df[col].dropna().empty else "NaN"
                if len(sample_val) > 50:
                    sample_val = sample_val[:47] + "..."
                    
                column_inventory.append({
                    'file_path': rel_path,
                    'column_name': str(col),
                    'data_type': str(df[col].dtype),
                    'missing_percentage': round(missing_pct, 2),
                    'unique_count': unique_cnt,
                    'sample_value': sample_val,
                    'classification': classify_column(col),
                    'notes': ''
                })
                
        except Exception as e:
            print(f"Error processing {filepath}: {e}")

df_ds = pd.DataFrame(dataset_inventory)
df_cols = pd.DataFrame(column_inventory)

df_ds.to_csv(os.path.join(base_dir, 'dataset_inventory.csv'), index=False)
df_cols.to_csv(os.path.join(base_dir, 'column_inventory.csv'), index=False)

md_content = f"""# Dataset Inspection Report

## Summary
- **Number of files inspected:** {file_count}
- **Number of datasets parsed:** {dataset_count}

## 1. Important Dataset Groups Found
"""

if len(df_ds) > 0:
    groups = df_ds['dataset_name'].unique()
    for g in groups:
        md_content += f"- {g}\n"

md_content += """
## 2. Possible Common Keys
"""
if len(df_ds) > 0:
    all_cow_ids = set([x.strip() for items in df_ds['cow_id_candidate'].dropna() for x in items.split(',') if x.strip()])
    md_content += f"- **Cow/Animal IDs:** {', '.join(all_cow_ids) if all_cow_ids else 'None found'}\n"
    all_dates = set([x.strip() for items in df_ds['date_candidate'].dropna() for x in items.split(',') if x.strip()])
    md_content += f"- **Dates:** {', '.join(all_dates) if all_dates else 'None found'}\n"
    all_times = set([x.strip() for items in df_ds['timestamp_candidate'].dropna() for x in items.split(',') if x.strip()])
    md_content += f"- **Timestamps:** {', '.join(all_times) if all_times else 'None found'}\n"

md_content += """
## 3. Possible Target Columns
"""
if len(df_ds) > 0:
    all_targets = set([x.strip() for items in df_ds['target_candidate'].dropna() for x in items.split(',') if x.strip()])
    md_content += f"- {', '.join(all_targets) if all_targets else 'None found'}\n"

md_content += """
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
"""

with open(os.path.join(base_dir, 'dataset_inspection_report.md'), 'w') as f:
    f.write(md_content)

print(f"Finished parsing. Datasets: {dataset_count}. Wrote output files.")
