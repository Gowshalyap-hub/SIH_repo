from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.api.dependencies import get_current_user, require_role
from app.models.user import User
from app.schemas.iot import IoTSmartCupPayload, IoTCollarPayload, IoTThermometerPayload
from app.services.iot_ingestion import ingest_smart_cup_reading, ingest_collar_reading, ingest_temperature_reading

router = APIRouter()

# Note: In real life, IoT endpoints might use different auth (e.g. API keys for devices)
# But for development HTTP fallback, we can use the same current_user logic if a mobile app sends it,
# or no auth if we just want to test injection. We will use get_current_user to ensure safety.

@router.post("/smart-cup/readings")
def add_smart_cup_reading(payload: IoTSmartCupPayload, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        reading = ingest_smart_cup_reading(db, payload)
        return {"status": "success", "reading_id": reading.id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/collar/readings")
def add_collar_reading(payload: IoTCollarPayload, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        reading = ingest_collar_reading(db, payload)
        return {"status": "success", "reading_id": reading.id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/temperature/readings")
def add_temperature_reading(payload: IoTThermometerPayload, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        reading = ingest_temperature_reading(db, payload)
        return {"status": "success", "reading_id": reading.id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/wokwi-fallback")
def wokwi_fallback(payload_dict: dict, db: Session = Depends(get_db)):
    # This endpoint mimics the MQTT adapter for Wokwi payloads when broker is unavailable
    try:
        from datetime import datetime
        current_time = payload_dict.get("timestamp") or datetime.utcnow().isoformat()
        
        if "milk_temperature" in payload_dict or "milk_yield" in payload_dict:
            sc_payload = IoTSmartCupPayload(
                smart_cup_id=payload_dict.get("smart_cup_id", "WOKWI-SC-1"),
                session_id=payload_dict.get("session_id", None),
                cow_id=payload_dict.get("cow_id", None) or payload_dict.get("Cow ID", None),
                milk_temperature=payload_dict.get("milk_temperature", 0.0),
                milk_conductivity=payload_dict.get("milk_conductivity", 0.0),
                milk_yield=payload_dict.get("milk_yield", 0.0),
                milk_ph=payload_dict.get("milk_ph", None),
                spectral_f1=payload_dict.get("spectral_f1", None),
                spectral_f2=payload_dict.get("spectral_f2", None),
                spectral_f3=payload_dict.get("spectral_f3", None),
                spectral_f4=payload_dict.get("spectral_f4", None),
                timestamp=current_time
            )
            ingest_smart_cup_reading(db, sc_payload)

        if "Activity" in payload_dict or "Rumination" in payload_dict:
            col_payload = IoTCollarPayload(
                collar_device_id=payload_dict.get("collar_device_id", "WOKWI-COL-1"),
                activity_level=payload_dict.get("Activity", "normal"),
                acceleration_magnitude=payload_dict.get("Acceleration", None),
                rumination_minutes=payload_dict.get("Rumination", 0.0),
                rumination_sound_level=payload_dict.get("RuminationSound", None),
                humidity=payload_dict.get("Humidity", None),
                timestamp=current_time
            )
            ingest_collar_reading(db, col_payload)
            
        if "BodyTemp" in payload_dict:
            temp_payload = IoTThermometerPayload(
                device_id=payload_dict.get("collar_device_id", "WOKWI-COL-1"),
                temperature=payload_dict.get("BodyTemp", 0.0),
                timestamp=current_time
            )
            ingest_temperature_reading(db, temp_payload)
            
        return {"status": "success", "message": "Wokwi payload processed via HTTP fallback"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")
