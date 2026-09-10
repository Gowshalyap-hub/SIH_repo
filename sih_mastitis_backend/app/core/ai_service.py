import os
import joblib
import pandas as pd
from typing import Dict, Any

class AIService:
    def __init__(self):
        # Allow overriding via environment variable
        model_path = os.getenv(
            "MASTITIS_MODEL_PATH",
            os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../datasets/ml_models/mastitis_current_state_baseline.pkl"))
        )
        self.model = None
        self.features_used = ["Milk_Temperature", "Milk_Conductivity", "Milk_Yield"]
        self.model_name = "LogisticRegression Baseline"
        
        try:
            if os.path.exists(model_path):
                self.model = joblib.load(model_path)
            else:
                print(f"WARNING: Model file not found at {model_path}. AI Service will fail gracefully upon prediction.")
        except Exception as e:
            print(f"WARNING: Failed to load AI model from {model_path}. Error: {e}")

    def predict_current_state(self, temperature: float, conductivity: float, yield_volume: float) -> Dict[str, Any]:
        """
        Predict the current mastitis state based on live milk features.
        Returns predicted_class and mastitis_probability.
        """
        if self.model is None:
            raise RuntimeError("AI Model is not loaded. Cannot generate prediction.")
            
        # Ensure inputs are numeric and valid
        if pd.isna(temperature) or pd.isna(conductivity) or pd.isna(yield_volume):
            raise ValueError("Input features contain NaN values.")
            
        # Create a single-row DataFrame with the exact feature names the model expects
        input_data = pd.DataFrame([{
            "Milk_Temperature": float(temperature),
            "Milk_Conductivity": float(conductivity),
            "Milk_Yield": float(yield_volume)
        }])
        
        # Inference
        try:
            predicted_class = int(self.model.predict(input_data)[0])
            mastitis_probability = float(self.model.predict_proba(input_data)[0, 1])
        except Exception as e:
            raise RuntimeError(f"Model inference failed: {e}")
            
        return {
            "prediction_type": "current_state_classification",
            "predicted_class": predicted_class,
            "mastitis_probability": mastitis_probability,
            "model_name": self.model_name,
            "features_used": self.features_used,
            "warning": "Baseline classification only; not a 7–14 day forecast or medical diagnosis."
        }

# Instantiate a singleton for the app to use
ai_service = AIService()
