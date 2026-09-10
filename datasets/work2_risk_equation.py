import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix

# STEP 1: Load raw data
df = pd.read_csv(r'c:\Users\gowth\Desktop\SIH\datasets\archive (7)\cow_milk_mastitis_dataset.csv')

# STEP 2 & 3: Selected hardware parameters based on analysis
# Milk_Temperature, Milk_Conductivity, Milk_Yield

# STEP 5: Normalization
# We use min-max normalization based on dataset bounds
temp_min, temp_max = 34.0, 40.0
cond_min, cond_max = 3.0, 9.0
yield_min, yield_max = 4.0, 30.0

df['temp_norm'] = np.clip((df['Milk_Temperature'] - temp_min) / (temp_max - temp_min), 0, 1)
df['cond_norm'] = np.clip((df['Milk_Conductivity'] - cond_min) / (cond_max - cond_min), 0, 1)
df['yield_norm'] = np.clip((yield_max - df['Milk_Yield']) / (yield_max - yield_min), 0, 1)

# STEP 4: Risk Equation
# Weights derived from absolute correlation proportions:
# Temp: 0.901 -> 34%
# Cond: 0.923 -> 35%
# Yield: -0.835 -> 31%
w_temp = 0.34
w_cond = 0.35
w_yield = 0.31

df['risk_score'] = (w_temp * df['temp_norm'] + w_cond * df['cond_norm'] + w_yield * df['yield_norm']) * 100

# STEP 6: Risk Thresholds
# Based on group distribution: Class 0 max is ~45, Class 1 min is ~55
def get_risk_level(score):
    if score < 40:
        return 'LOW'
    elif score < 60:
        return 'MODERATE'
    else:
        return 'HIGH'

df['risk_level'] = df['risk_score'].apply(get_risk_level)

# For validation against ground truth: HIGH/MODERATE -> 1, LOW -> 0
df['pred_class1'] = df['risk_level'].apply(lambda x: 1 if x in ['HIGH', 'MODERATE'] else 0)

# STEP 7: Validation
if 'class1' in df.columns:
    y_true = df['class1']
    y_pred = df['pred_class1']
    
    print('Accuracy:', accuracy_score(y_true, y_pred))
    print('Precision:', precision_score(y_true, y_pred))
    print('Recall:', recall_score(y_true, y_pred))
    print('F1-score:', f1_score(y_true, y_pred))
    print('Confusion Matrix:\n', confusion_matrix(y_true, y_pred))

# Save results
df.to_csv(r'c:\Users\gowth\Desktop\SIH\datasets\work2_equation_results.csv', index=False)
print('Results saved to work2_equation_results.csv')
