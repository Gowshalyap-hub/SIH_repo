# API Model Integration Documentation

## Model Integration Details

- **Model File**: `datasets/ml_models/mastitis_current_state_baseline.pkl`
- **Model Type**: Current-State Mastitis Classification Baseline
- **Features Used**: `Milk_Temperature`, `Milk_Conductivity`, `Milk_Yield`
- **Algorithm**: Logistic Regression with StandardScaler preprocessing

## API Endpoint Details

- **Endpoint**: `POST /api/v1/cows/{cow_id}/prediction`
- **Description**: Receives live milk telemetry data, feeds it to the loaded Logistic Regression model, and returns a binary classification prediction and probability for current mastitis presence.

### Request Format (JSON)

```json
{
  "milk_temperature": 38.5,
  "milk_conductivity": 5.2,
  "milk_yield": 8.4
}
```

### Response Format (JSON)

```json
{
  "id": 1,
  "cow_id": "cow_001",
  "prediction_type": "current_state_classification",
  "predicted_class": 0,
  "mastitis_probability": 0.05,
  "model_name": "LogisticRegression Baseline",
  "features_used": [
    "Milk_Temperature",
    "Milk_Conductivity",
    "Milk_Yield"
  ],
  "warning": "Baseline classification only; not a 7–14 day forecast or medical diagnosis.",
  "timestamp": "2026-09-02T10:00:00Z"
}
```

## Model Limitations (CRITICAL)

- **Current-State Classification Only**: This model ONLY predicts the current state based on point-in-time telemetry.
- **No 7–14 Day Forecasting**: The raw dataset used for this model lacks longitudinal depth and cannot be shifted temporally. Therefore, this model **must not be presented as an early forecasting tool**.
- **No Clinical Validation**: The 1.00 perfect accuracy is due to synthetic/idealized characteristics in the open-source snapshot dataset. It is functionally reliable as a software integration baseline for the Smart Cup backend but lacks real-world medical/clinical validity.
- **No Diagnostic Inputs**: Diagnostic metrics (SCC, pH) and observational signs (Clotting) are strictly excluded from the inputs to simulate live Smart Cup telemetry conditions and prevent target leakage.

## Flutter Compatibility Steps

To integrate this API seamlessly into the Flutter `sih_mastitis_app`:

1.  **Update `AIPrediction` Model in Dart**: Update the data model to reflect the new API response fields (`prediction_type`, `predicted_class`, `mastitis_probability`, `model_name`, `warning`).
2.  **Adjust API Service**: Ensure the `POST` request correctly serializes the three numerical features (`milk_temperature`, `milk_conductivity`, `milk_yield`).
3.  **UI Updates**: 
    *   Since the API does not map to four risk levels (`NO RISK`, `LOW RISK`, `MODERATE RISK`, `HIGH RISK`), the UI should display the raw probability (e.g., "95%") or a simple binary indicator (e.g., "Normal" vs "Alert") for now. 
    *   Do not fabricate four risk levels on the client side without proper threshold calibration from future models.
    *   Display the `warning` string to the user prominently near the prediction.
