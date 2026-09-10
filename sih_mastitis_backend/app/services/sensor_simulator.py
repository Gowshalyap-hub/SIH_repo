from datetime import datetime
import random

def generate_mock_smart_cup_payload(smart_cup_id: str, session_id: str = None) -> dict:
    """Generates a DEVELOPMENT ONLY payload for SmartCup."""
    return {
        "smart_cup_id": smart_cup_id,
        "session_id": session_id,
        "milk_temperature": round(random.uniform(37.5, 39.5), 1),
        "milk_conductivity": round(random.uniform(4.5, 6.5), 2),
        "milk_yield": round(random.uniform(5.0, 15.0), 1),
        "timestamp": datetime.utcnow().isoformat()
    }

def generate_mock_collar_payload(collar_device_id: str) -> dict:
    """Generates a DEVELOPMENT ONLY payload for Collar."""
    return {
        "collar_device_id": collar_device_id,
        "activity_level": random.choice(["low", "normal", "high"]),
        "rumination_minutes": round(random.uniform(20.0, 50.0), 1),
        "timestamp": datetime.utcnow().isoformat()
    }

def generate_mock_temperature_payload(device_id: str, cow_id: str = None) -> dict:
    """Generates a DEVELOPMENT ONLY payload for Temperature module."""
    return {
        "device_id": device_id,
        "cow_id": cow_id,
        "temperature": round(random.uniform(38.0, 40.0), 1),
        "timestamp": datetime.utcnow().isoformat()
    }
