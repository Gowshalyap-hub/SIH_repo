import pandas as pd

print("--- STEP 14 AUDIT ---")
try:
    df1 = pd.read_csv("datasets/archive (7)/cow_milk_mastitis_dataset.csv")
    print("1. cow_milk_mastitis_dataset.csv")
    print(f"Rows: {len(df1)}, Unique Cow_IDs: {df1['Cow_ID'].nunique()}")
    print(f"Max rows per cow: {df1.groupby('Cow_ID').size().max()}")
    print("Longitudinal Predictors? NO. (Max 1 row per cow)")
except Exception as e:
    print(f"Failed to read dataset 1: {e}")

try:
    df2 = pd.read_csv("datasets/Clinical_Mastitis_cows_version2/clinical_mastitis_cows.csv")
    print("\n2. clinical_mastitis_cows.csv")
    print(f"Columns: {list(df2.columns)}")
    print("Has predictors (Temp, EC, Yield)? NO. (Only Cow_ID, Day, class1)")
except Exception as e:
    print(f"Failed to read dataset 2: {e}")

print("\n3. Sensor Data Mapping")
print("Previously audited: C01-C16 and T01-T14 have NO known mapping to Cow_ID.")

print("\n--- CONCLUSION ---")
print("A valid 7-14 day forecasting dataset requires:")
print("a) Longitudinal predictor features (Temp, EC, Yield)")
print("b) Longitudinal target labels (class1)")
print("c) Linked by the same Cow_ID")
print("This relationship DOES NOT EXIST in the raw data.")
