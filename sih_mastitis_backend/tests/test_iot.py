import pytest
from fastapi.testclient import TestClient
from datetime import datetime
from app.main import app
from app.api.dependencies import get_current_user
from app.models.user import User

client = TestClient(app)

def override_get_current_user():
    return User(id=1, email="test@test.com", role="FARMER", farm_id=1)

app.dependency_overrides[get_current_user] = override_get_current_user

# --- Helper Data ---
VALID_SMARTCUP_PAYLOAD = {
    "smart_cup_id": "SC-123",
    "milk_temperature": 38.5,
    "milk_conductivity": 5.2,
    "milk_yield": 12.4,
    "milk_ph": 6.8,
    "spectral_f1": 100.0,
    "spectral_f2": 200.0,
    "spectral_f3": 300.0,
    "spectral_f4": 400.0,
    "timestamp": datetime.utcnow().isoformat()
}

VALID_COLLAR_PAYLOAD = {
    "collar_device_id": "COL-456",
    "activity_level": "normal",
    "acceleration_magnitude": 10.5,
    "rumination_minutes": 35.5,
    "rumination_sound_level": 500.0,
    "humidity": 65.2,
    "timestamp": datetime.utcnow().isoformat()
}

VALID_TEMP_PAYLOAD = {
    "device_id": "TMP-789",
    "cow_id": "COW-001",
    "temperature": 39.1,
    "timestamp": datetime.utcnow().isoformat()
}

# 1. Valid SmartCup payload (Assumes a mock session flow)
def test_valid_smartcup_payload():
    # Because we don't have a real session in test DB here natively, 
    # we'll just test that the validation accepts the format but might fail at business logic
    response = client.post("/api/v1/iot/smart-cup/readings", json=VALID_SMARTCUP_PAYLOAD)
    # 400 means business logic rejected it (no active session), but 422 would mean schema validation failed
    assert response.status_code in [200, 400]

# 2. Invalid SmartCup payload (Missing field)
def test_invalid_smartcup_payload():
    invalid_payload = VALID_SMARTCUP_PAYLOAD.copy()
    del invalid_payload["milk_temperature"]
    response = client.post("/api/v1/iot/smart-cup/readings", json=invalid_payload)
    assert response.status_code == 422

# 7. Valid Collar Payload
def test_valid_collar_payload():
    response = client.post("/api/v1/iot/collar/readings", json=VALID_COLLAR_PAYLOAD)
    assert response.status_code == 200

# 8. Invalid Collar payload
def test_invalid_collar_payload():
    invalid_payload = VALID_COLLAR_PAYLOAD.copy()
    invalid_payload["rumination_minutes"] = "not a number"
    response = client.post("/api/v1/iot/collar/readings", json=invalid_payload)
    assert response.status_code == 422

# 9. Valid Temp payload
def test_valid_temperature_payload():
    response = client.post("/api/v1/iot/temperature/readings", json=VALID_TEMP_PAYLOAD)
    assert response.status_code == 200

# 14. NaN/infinite rejection
def test_reject_nan_infinity():
    import json
    # Use a string payload to bypass TestClient JSON encoding issues with Infinity
    nan_payload = VALID_TEMP_PAYLOAD.copy()
    nan_payload["temperature"] = "Infinity"
    response = client.post("/api/v1/iot/temperature/readings", json=nan_payload)
    assert response.status_code in [400, 422]
