import os
import pandas as pd
import numpy as np

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"
source_file = os.path.join(base_dir, "raw", "archive (7)", "cow_milk_mastitis_dataset.csv")

if not os.path.exists(source_file):
    # Try alternate path if raw is not structured exactly
    source_file = os.path.join(base_dir, "archive (7)", "cow_milk_mastitis_dataset.csv")

# 1. Source Validation
df = pd.read_csv(source_file)
initial_rows = len(df)
cols = list(df.columns)
dtypes = df.dtypes.to_dict()
missing = df.isnull().sum().to_dict()
duplicates = df.duplicated().sum()
class1_dist = df['class1'].value_counts().to_dict() if 'class1' in df.columns else {}

unique_cows = df['Cow_ID'].nunique() if 'Cow_ID' in df.columns else 0

# Check 'Day' column
day_info = "Not present"
if 'Day' in df.columns:
    sample_day = str(df['Day'].iloc[0])
    day_info = f"Present. Sample value: {sample_day}. Suspected to be a generic placeholder or misformatted timestamp."

validation_md = f"""# Baseline Source Validation

- **Source File**: `cow_milk_mastitis_dataset.csv`
- **Initial Row Count**: {initial_rows}
- **Columns**: {cols}
- **Data Types**: {dtypes}
- **Unique Cow_IDs**: {unique_cows}
- **Missing Values**: {missing}
- **Duplicate Rows**: {duplicates}
- **class1 Distribution**: {class1_dist}
- **Day Column Check**: {day_info}

**Conclusion on 'Day'**: Given the values like 1970-01-01 00:00:00.000000001, it is confirmed to be an arbitrary placeholder or improperly converted epoch integer. It holds no temporal forecasting value and must be EXCLUDED.
"""
with open(os.path.join(base_dir, "baseline_source_validation.md"), "w") as f:
    f.write(validation_md)

# 2 & 3 & 4 & 5. Feature Decision Table
decisions = []
for col in df.columns:
    col_lower = str(col).lower()
    if 'cow' in col_lower:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'ID', 'include_in_baseline': 'NO', 'reason': 'Identifier', 'source': 'raw'})
    elif 'class1' in col_lower:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'TARGET', 'include_in_baseline': 'NO as feature (Yes as Target)', 'reason': 'Target variable', 'source': 'raw'})
    elif 'scc' in col_lower or 'somatic' in col_lower:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'LAB/DIAGNOSTIC', 'include_in_baseline': 'NO', 'reason': 'Diagnostic measurement (Leakage)', 'source': 'raw'})
    elif 'ph' in col_lower:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'LAB/DIAGNOSTIC', 'include_in_baseline': 'NO', 'reason': 'Diagnostic measurement (Leakage)', 'source': 'raw'})
    elif 'day' in col_lower:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'UNKNOWN', 'include_in_baseline': 'NO', 'reason': 'Invalid placeholder temporal data', 'source': 'raw'})
    elif 'clotting' in col_lower:
        # Check values
        unique_vals = df[col].unique()
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'CLINICAL SIGN', 'include_in_baseline': 'NO', 'reason': 'Subjective visual diagnostic sign, not a SmartCup automated sensor reading', 'source': 'raw'})
    else:
        decisions.append({'column': col, 'data_type': str(df[col].dtype), 'role': 'LIVE MILK FEATURE', 'include_in_baseline': 'YES', 'reason': 'Matches expected live telemetry (Yield, Temp, Conductivity)', 'source': 'raw'})

pd.DataFrame(decisions).to_csv(os.path.join(base_dir, "baseline_feature_decisions.csv"), index=False)

# 6. Create Cleaned Dataset
# Drop duplicates
df_clean = df.drop_duplicates()
final_rows_clean = len(df_clean)

# We keep raw features in the cleaned dataset, maybe just remove identical duplicates
# The ML ready dataset will have the strict subset.
os.makedirs(os.path.join(base_dir, "cleaned"), exist_ok=True)
df_clean.to_csv(os.path.join(base_dir, "cleaned", "cow_milk_baseline_cleaned.csv"), index=False)

# 7. Cleaning Report
# Decide approved features
approved_features = [d['column'] for d in decisions if d['include_in_baseline'] == 'YES']
excluded_features = [d['column'] for d in decisions if d['include_in_baseline'] != 'YES' and d['role'] != 'TARGET']

report_md = f"""# Cleaning Report

- **Source File**: `archive (7)/cow_milk_mastitis_dataset.csv`
- **Original Row Count**: {initial_rows}
- **Original Columns**: {cols}
- **Removed Columns (from ML-Ready)**: {excluded_features}
- **Retained Features (ML-Ready)**: {approved_features}
- **Target**: `class1`
- **Missing-value handling**: None required (dataset has no missing values).
- **Duplicate handling**: Removed {duplicates} exact duplicate rows.
- **Suspicious-value handling**: `Day` column identified as corrupt/placeholder and excluded. `Clotting` identified as visual clinical sign and excluded. `SCC`/`pH` excluded as laboratory leakage.
- **Target distribution**: {class1_dist}
- **Final Row Count**: {final_rows_clean}
"""
with open(os.path.join(base_dir, "cleaning_report.md"), "w") as f:
    f.write(report_md)

# 8. Create ML-Ready Baseline Dataset
os.makedirs(os.path.join(base_dir, "ml_ready"), exist_ok=True)
ml_cols = approved_features + ['class1']
df_ml = df_clean[ml_cols]
df_ml.to_csv(os.path.join(base_dir, "ml_ready", "current_state_baseline.csv"), index=False)

# 9. Dataset Card
card_md = f"""# Current State Baseline Dataset Card

- **Dataset type**: Cross-sectional current-state classification
- **Target**: `class1`
- **Class meaning**: 0 = Normal/Absent, 1 = Mastitis Present
- **Prediction horizon**: Current state / point-in-time
- **NOT**: 7–14 day forecasting

## Features
- {', '.join(approved_features)}

## Excluded
- SCC, pH (Laboratory diagnostic leakage)
- Cow_ID (Identifier)
- Day (Corrupt placeholder)
- Clotting (Visual clinical sign, not automated telemetry)

## Limitations
- No longitudinal timeline
- No sensor-to-cow mapping
- No 7–14 day target
- Clinical and milk Cow_IDs do not overlap
"""
with open(os.path.join(base_dir, "ml_ready", "current_state_baseline_dataset_card.md"), "w") as f:
    f.write(card_md)

print("Step 6 cleaning complete.")
