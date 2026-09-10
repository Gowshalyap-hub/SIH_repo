import os
import pytest
from app.core.ai_service import ai_service

def test_ai_service_predicts_correctly():
    # 1. loads the actual .pkl model (ai_service handles this)
    assert ai_service.model is not None, "AI Model failed to load"
    
    # 2. sends a valid feature vector
    # 3. obtains prediction
    # 4. obtains probability
    result = ai_service.predict_current_state(
        temperature=38.5,
        conductivity=5.2,
        yield_volume=8.4
    )
    
    # 5. verifies probability is between 0 and 1
    assert 0.0 <= result["mastitis_probability"] <= 1.0
    
    # 6. verifies predicted_class is 0 or 1
    assert result["predicted_class"] in [0, 1]
    
    # Check that forbidden features are not in the used list
    used_features = result["features_used"]
    for forbidden in ["SCC", "Somatic_Cell_Count", "Milk_pH", "Cow_ID", "Day", "Clotting"]:
        assert forbidden not in used_features
