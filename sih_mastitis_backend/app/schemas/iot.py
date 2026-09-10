from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class IoTSmartCupPayload(BaseModel):
    smart_cup_id: str
    session_id: Optional[str] = None
    cow_id: Optional[str] = None
    milk_temperature: float
    milk_conductivity: float
    milk_yield: float
    milk_ph: Optional[float] = None
    spectral_f1: Optional[float] = None
    spectral_f2: Optional[float] = None
    spectral_f3: Optional[float] = None
    spectral_f4: Optional[float] = None
    timestamp: datetime

class IoTCollarPayload(BaseModel):
    collar_device_id: str
    activity_level: str
    acceleration_magnitude: Optional[float] = None
    rumination_minutes: float
    rumination_sound_level: Optional[float] = None
    humidity: Optional[float] = None
    timestamp: datetime

class IoTThermometerPayload(BaseModel):
    device_id: str
    cow_id: Optional[str] = None
    temperature: float
    timestamp: datetime
