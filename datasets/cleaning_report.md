# Cleaning Report

- **Source File**: `archive (7)/cow_milk_mastitis_dataset.csv`
- **Original Row Count**: 800
- **Original Columns**: ['Cow_ID', 'Day', 'Milk_Temperature', 'Milk_pH', 'Milk_Conductivity', 'Somatic_Cell_Count', 'Milk_Yield', 'Clotting', 'class1']
- **Removed Columns (from ML-Ready)**: ['Cow_ID', 'Day', 'Milk_pH', 'Somatic_Cell_Count', 'Clotting']
- **Retained Features (ML-Ready)**: ['Milk_Temperature', 'Milk_Conductivity', 'Milk_Yield']
- **Target**: `class1`
- **Missing-value handling**: None required (dataset has no missing values).
- **Duplicate handling**: Removed 0 exact duplicate rows.
- **Suspicious-value handling**: `Day` column identified as corrupt/placeholder and excluded. `Clotting` identified as visual clinical sign and excluded. `SCC`/`pH` excluded as laboratory leakage.
- **Target distribution**: {0: 631, 1: 169}
- **Final Row Count**: 800
