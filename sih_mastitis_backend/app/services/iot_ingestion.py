from sqlalchemy.orm import Session
from app.models.cow import Cow
from app.models.smart_cup import SmartCup
from app.models.milking_session import MilkingSession
from app.models.readings import MilkReading, CollarReading, TemperatureReading
from app.models.data_entry import LabRecord
from app.schemas.iot import IoTSmartCupPayload, IoTCollarPayload, IoTThermometerPayload
import uuid

def ingest_smart_cup_reading(db: Session, payload: IoTSmartCupPayload):
    # Ensure all values are finite and not NaN
    if any(map(lambda x: x != x or float(x) == float('inf') or float(x) == float('-inf'), 
               [payload.milk_temperature, payload.milk_conductivity, payload.milk_yield])):
        raise ValueError("Invalid numeric values in payload (NaN or infinity).")

    # If session is provided, try to find it. Otherwise, fail if no cow can be deduced.
    if payload.session_id:
        session = db.query(MilkingSession).filter(MilkingSession.id == payload.session_id).first()
        if not session:
            raise ValueError("Milking session not found.")
    elif payload.cow_id:
        # Try to find cow by RFID or ID
        cow = db.query(Cow).filter((Cow.rfid == payload.cow_id) | (Cow.id == payload.cow_id)).first()
        if not cow:
            # Fallback graceful demo mapping if cow not found (create mock one or fail gracefully)
            # The user states: "If the RFID UID does not exist... gracefully handle it... Do NOT invent a permanent mapping silently."
            raise ValueError(f"Cow with RFID {payload.cow_id} not found in database. Scan a valid RFID.")
        
        # Check if there is an active session for this cow
        session = db.query(MilkingSession).filter(
            MilkingSession.cow_id == cow.id,
            MilkingSession.end_time.is_(None)
        ).order_by(MilkingSession.start_time.desc()).first()

        # If not, create one! This makes it a shared Smart Cup!
        if not session:
            session = MilkingSession(
                id=str(uuid.uuid4()),
                cow_id=cow.id,
                smart_cup_id=payload.smart_cup_id,
                start_time=payload.timestamp
            )
            db.add(session)
            db.flush()
    else:
        # Check if there is an active session for this smart cup
        session = db.query(MilkingSession).filter(
            MilkingSession.smart_cup_id == payload.smart_cup_id,
            MilkingSession.end_time.is_(None)
        ).order_by(MilkingSession.start_time.desc()).first()
        
        if not session:
            raise ValueError("No active milking session found for this smart cup. Scan RFID first.")

    # Record the reading
    reading = MilkReading(
        session_id=session.id,
        yield_volume=payload.milk_yield,
        ec=payload.milk_conductivity,
        temperature=payload.milk_temperature,
        spectral_f1=payload.spectral_f1,
        spectral_f2=payload.spectral_f2,
        spectral_f3=payload.spectral_f3,
        spectral_f4=payload.spectral_f4,
        timestamp=payload.timestamp
    )
    db.add(reading)
    
    # If pH is provided, store it strictly as a LabRecord to segregate it from live ML features
    if payload.milk_ph is not None:
        lab_record = LabRecord(
            cow_id=session.cow_id,
            ph=payload.milk_ph,
            scc=0,
            recorded_by=1,
            timestamp=payload.timestamp
        )
        db.add(lab_record)
        
    db.commit()
    db.refresh(reading)
    return reading

def ingest_collar_reading(db: Session, payload: IoTCollarPayload):
    # Collar readings don't need a session, just validate inputs
    if payload.rumination_minutes != payload.rumination_minutes or float(payload.rumination_minutes) in [float('inf'), float('-inf')]:
        raise ValueError("Invalid numeric values for rumination.")

    reading = CollarReading(
        collar_id=payload.collar_device_id,
        activity_level=payload.activity_level,
        acceleration_magnitude=payload.acceleration_magnitude,
        rumination_minutes=payload.rumination_minutes,
        rumination_sound_level=payload.rumination_sound_level,
        body_temperature=0.0, # Kept safe default, logic handles it in other endpoints if needed
        humidity=payload.humidity,
        timestamp=payload.timestamp
    )
    db.add(reading)
    db.commit()
    db.refresh(reading)
    return reading

def ingest_temperature_reading(db: Session, payload: IoTThermometerPayload):
    if payload.temperature != payload.temperature or float(payload.temperature) in [float('inf'), float('-inf')]:
        raise ValueError("Invalid numeric values for temperature.")

    reading = TemperatureReading(
        device_id=payload.device_id,
        cow_id=payload.cow_id, # Can be null if unresolved
        temperature=payload.temperature,
        timestamp=payload.timestamp
    )
    db.add(reading)
    db.commit()
    db.refresh(reading)
    return reading
