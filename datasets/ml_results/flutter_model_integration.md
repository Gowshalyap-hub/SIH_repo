# Flutter ML Prediction Integration

This document outlines the successful integration of the Flutter application with the live FastAPI baseline machine learning model (`mastitis_current_state_baseline.pkl`).

## Architecture Flow

`Smart Milk Workflow` -> `SmartMilkReviewScreen` -> `PredictionProvider` -> `ApiAIService` -> `POST /api/v1/cows/{cow_id}/prediction` -> `FastAPI` -> `ai_service.py` -> `LogisticRegression.pkl`

## Request Payload

The frontend `ApiAIService.getPrediction` sends a POST request with the following JSON payload using values collected live from the Smart Cup (or defaults if unavailable):
```json
{
  "milk_temperature": 38.0,
  "milk_conductivity": 4.5,
  "milk_yield": 10.0
}
```

## Response Parsing

The `AIPrediction` model in Flutter parses the following JSON response:
```json
{
  "id": "1",
  "cow_id": "cow_001",
  "prediction_type": "current_state_classification",
  "predicted_class": 0,
  "mastitis_probability": 0.05,
  "model_name": "LogisticRegression Baseline",
  "features_used": ["Milk_Temperature", "Milk_Conductivity", "Milk_Yield"],
  "warning": "Baseline classification only; not a 7–14 day forecast or medical diagnosis.",
  "timestamp": "2026-09-02T10:00:00Z"
}
```

## UI and Localization Updates

- **Localization keys added**: Added `current_state_classification`, `predicted_status`, `mastitis_probability`, `baseline_model`, `features_used`, `not_forecast_warning`, `normal`, `mastitis_present`, `failed_to_load_prediction` to `en.json`, `hi.json`, `ta.json`.
- **UI Screen (`PredictionScreen`)**: Cleaned up to reflect binary classification instead of 4 risk levels. Shows probabilities visually as `(probability * 100)%`. Warning strings are rendered directly from the backend.
- **Smart Milk Integration (`SmartMilkReviewScreen`)**: Saving a Smart Milk Session successfully sends the live `temperature`, `conductivity`, and `yield` values to the backend to generate an updated prediction. No permanent Smart Cup to Cow association is saved, adhering to the physical shared-cup reality.

## Error Handling

All HTTP errors (`400, 422, 500, timeouts`) caught by `ApiAIService` are thrown as Dart exceptions, causing the `PredictionProvider` to nullify `_currentPrediction` and set the `_error` state to a localized string (`failed_to_load_prediction`), which gracefully displays on the `PredictionScreen`.

## Critical Limitations

- **No Diagnostic Features**: As established during data analysis, `SCC` and `pH` are completely hidden from the request payload to prevent target leakage.
- **Current State Only**: The UI explicitly disclaims 7-14 day forecasting.
