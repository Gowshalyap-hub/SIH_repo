# Step 14 Genuine 7-14 Day Mastitis Forecasting Feasibility Audit

**1. Objective**
Determine whether the currently available datasets genuinely support a 7–14 day mastitis forecasting task using only information that would have been available on or before day D to predict a first mastitis onset between D+7 and D+14.

**2. Data Relationship Requirements**
To train a valid supervised 7-14 day forecasting model, the dataset MUST contain:
a) **Longitudinal Predictor Features**: High-frequency or daily records of milk temperature, conductivity, and yield.
b) **Longitudinal Target Labels**: Accurate clinical timeline of mastitis onset (class1) representing Day D+7 to D+14.
c) **Identifier Linking**: A reliable `Cow_ID` joining the predictor features to the clinical timeline.

**3. Current Dataset Audit Findings**
- **cow_milk_mastitis_dataset.csv**: Contains 800 snapshot rows with features (Temp, EC, Yield) and `class1`, but it is cross-sectional data (maximum 1 row per cow). It contains no historical timeline, rendering it impossible to establish a "Day D" vs "Day D+7" relationship.
- **clinical_mastitis_cows.csv**: Contains a longitudinal clinical timeline (`Cow_ID`, `Day`, `class1`), but it completely lacks the predictor features (Temp, EC, Yield).
- **Sensor Data (C01-C16, T01-T14)**: Contains high-frequency longitudinal sensor data but has **zero confirmed mapping** to any clinical `Cow_ID`.

**4. Conclusion**
**GENUINE 7-14 DAY FORECASTING IS NOT FEASIBLE.**
The critical data relationship cannot be established. No single dataset or combination of mappable datasets contains longitudinal predictor features linked to a future longitudinal target label for the same cow.

**5. Action Taken**
In accordance with the non-negotiable project rules (no data fabrication, no artificial label shifting, no fake Device_ID mapping), model training for 7-14 day forecasting has been **ABORTED**. 

The backend, Flutter application, and current-state ML model (`mastitis_current_state_baseline.pkl`) remain untouched. We maintain the current system exclusively as a Current-State Classification baseline.
