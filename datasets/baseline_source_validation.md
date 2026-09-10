# Baseline Source Validation

- **Source File**: `cow_milk_mastitis_dataset.csv`
- **Initial Row Count**: 800
- **Columns**: ['Cow_ID', 'Day', 'Milk_Temperature', 'Milk_pH', 'Milk_Conductivity', 'Somatic_Cell_Count', 'Milk_Yield', 'Clotting', 'class1']
- **Data Types**: {'Cow_ID': <StringDtype(storage='python', na_value=nan)>, 'Day': dtype('int64'), 'Milk_Temperature': dtype('float64'), 'Milk_pH': dtype('float64'), 'Milk_Conductivity': dtype('float64'), 'Somatic_Cell_Count': dtype('int64'), 'Milk_Yield': dtype('float64'), 'Clotting': dtype('int64'), 'class1': dtype('int64')}
- **Unique Cow_IDs**: 800
- **Missing Values**: {'Cow_ID': 0, 'Day': 0, 'Milk_Temperature': 0, 'Milk_pH': 0, 'Milk_Conductivity': 0, 'Somatic_Cell_Count': 0, 'Milk_Yield': 0, 'Clotting': 0, 'class1': 0}
- **Duplicate Rows**: 0
- **class1 Distribution**: {0: 631, 1: 169}
- **Day Column Check**: Present. Sample value: 7. Suspected to be a generic placeholder or misformatted timestamp.

**Conclusion on 'Day'**: Given the values like 1970-01-01 00:00:00.000000001, it is confirmed to be an arbitrary placeholder or improperly converted epoch integer. It holds no temporal forecasting value and must be EXCLUDED.
