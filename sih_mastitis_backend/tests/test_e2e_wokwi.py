import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.db.database import get_db, Base
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Create a test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_e2e.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture(scope="module", autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    # Seed some initial data
    from app.models.farm import Farm
    from app.models.cow import Cow
    from app.models.milking_session import MilkingSession
    from app.models.smart_cup import SmartCup
    from app.models.collar import CollarDevice
    
    farm = Farm(id=1, name="Test Farm", owner_id=1)
    db.add(farm)
    
    sc = SmartCup(id="WOKWI-SC-1", mac_address="MAC-SC-1")
    col1 = CollarDevice(id="WOKWI-COL-1", mac_address="MAC-COL-1")
    col2 = CollarDevice(id="WOKWI-COL-2", mac_address="MAC-COL-2")
    db.add(sc)
    db.add(col1)
    db.add(col2)
    
    cow_a = Cow(id="C-A", farm_id=1, rfid="100", breed="Holstein", collar_id="WOKWI-COL-1")
    cow_b = Cow(id="C-B", farm_id=1, rfid="101", breed="Jersey", collar_id="WOKWI-COL-2")
    db.add(cow_a)
    db.add(cow_b)
    
    from datetime import datetime
    session_a = MilkingSession(id="SESSION-A", cow_id="C-A", smart_cup_id="WOKWI-SC-1", start_time=datetime.utcnow())
    session_b = MilkingSession(id="SESSION-B", cow_id="C-B", smart_cup_id="WOKWI-SC-1", start_time=datetime.utcnow())
    db.add(session_a)
    db.add(session_b)
    
    db.commit()
    db.close()
    yield
    Base.metadata.drop_all(bind=engine)

def test_wokwi_sampling_cup_flow():
    # Simulate Wokwi Smart Cup Payload for Cow A
    payload = {
        "smart_cup_id": "WOKWI-SC-1",
        "session_id": "SESSION-A",
        "milk_temperature": 38.5,
        "milk_yield": 12.5,
        "milk_ph": 6.8,
        "spectral_f1": 100,
        "spectral_f2": 200,
        "spectral_f3": 300,
        "spectral_f4": 400
    }
    
    response = client.post("/api/v1/iot/wokwi-fallback", json=payload)
    if response.status_code != 200:
        raise AssertionError(response.json())
    
    # Verify in DB
    db = TestingSessionLocal()
    from app.models.readings import MilkReading
    from app.models.data_entry import LabRecord
    
    mr = db.query(MilkReading).filter(MilkReading.session_id == "SESSION-A").first()
    assert mr is not None
    assert mr.temperature == 38.5
    assert mr.yield_volume == 12.5
    
    # Verify pH went to LabRecord
    lr = db.query(LabRecord).filter(LabRecord.cow_id == "C-A").first()
    assert lr is not None
    assert lr.ph == 6.8
    db.close()

def test_wokwi_collar_flow():
    # Simulate Wokwi Collar Payload for Cow A
    payload = {
        "collar_device_id": "WOKWI-COL-1",
        "Activity": "high",
        "Acceleration": 10.5,
        "Rumination": 35.5,
        "RuminationSound": 500.0,
        "BodyTemp": 39.1,
        "Humidity": 65.2
    }
    
    response = client.post("/api/v1/iot/wokwi-fallback", json=payload)
    if response.status_code != 200:
        raise AssertionError(response.json())
    
    # Verify in DB
    db = TestingSessionLocal()
    from app.models.readings import CollarReading, TemperatureReading
    
    cr = db.query(CollarReading).filter(CollarReading.collar_id == "WOKWI-COL-1").first()
    assert cr is not None
    assert cr.activity_level == "high" 
    assert cr.rumination_minutes == 35.5
    assert cr.rumination_sound_level == 500.0
    assert cr.humidity == 65.2
    
    tr = db.query(TemperatureReading).filter(TemperatureReading.device_id == "WOKWI-COL-1").first()
    assert tr is not None
    assert tr.temperature == 39.1
    db.close()
