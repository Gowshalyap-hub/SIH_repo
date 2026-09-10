# Current-State Mastitis Baseline Model Report

## 1. Objective
Build a baseline classification model using live-telemetry features to predict the current mastitis status of a cow.

## 2. Dataset Description
- **Type**: Cross-sectional
- **Rows**: 800
- **Warning**: This dataset contains NO valid temporal timeline.

## 3. Features
['Milk_Temperature', 'Milk_Conductivity', 'Milk_Yield']

## 4. Excluded variables
- `Cow_ID` (Identifier)
- `Day` (Corrupt placeholder)
- `Somatic_Cell_Count`, `Milk_pH` (Laboratory diagnostic leakage)
- `Clotting` (Visual subjective sign)

## 5. Target definition
`class1` (0 = Normal, 1 = Mastitis Present)

## 6. Class distribution
- Train: {0: 442, 1: 118}
- Val: {0: 94, 1: 26}
- Test: {0: 95, 1: 25}

## 7. Train/validation/test methodology
Stratified split (70/15/15) preserving class ratios. Because the data is cross-sectional, this is NOT a temporal split and implies point-in-time generalization only.

## 8. Models trained
['LogisticRegression', 'RandomForest', 'HistGradientBoosting']

## 9. Selected model
**LogisticRegression** was selected for achieving the best balance of Recall and F1 on the validation set.

## 10. Evaluation metrics (Test Set)
- Recall: 1.0
- F1: 1.0
- ROC-AUC: 1.0
- PR-AUC: 1.0

## 11. Confusion matrix interpretation
True Normal: 95, False Mastitis Alert: 0, Missed Mastitis: 0, True Mastitis: 25

## 12. Feature importance
See `datasets/ml_results/feature_importance.csv`. Note: Importance does not imply causality.

## 13. Limitations
No sensor-to-cow mapping. No longitudinal validation. No 7-14 day target. 

## 14. Deployment readiness
This is a BASELINE only. It confirms predictive signal exists in `(Yield, Temp, Conductivity)` but requires real-world longitudinal data collection to build a robust diagnostic system.

## 15. Explicit Statement
This model is a current-state classification baseline trained on a cross-sectional milk dataset. **It should not be interpreted as a 7-14 day mastitis forecasting model.**
