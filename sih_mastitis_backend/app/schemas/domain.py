from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from app.schemas.base import CowResponse

class CollarDeviceBase(BaseModel):
    id: str
    mac_address: str
    status: str = "active"

class CollarDeviceResponse(CollarDeviceBase):
    class Config:
        from_attributes = True

class SmartCupBase(BaseModel):
    id: str
    mac_address: str
    status: str = "active"

class SmartCupResponse(SmartCupBase):
    class Config:
        from_attributes = True

class MilkingSessionBase(BaseModel):
    id: str
    cow_id: str
    smart_cup_id: str
    start_time: datetime
    end_time: Optional[datetime] = None

class MilkingSessionCreate(MilkingSessionBase):
    pass

class MilkingSessionResponse(MilkingSessionBase):
    class Config:
        from_attributes = True

class MilkReadingBase(BaseModel):
    session_id: str
    yield_volume: float
    ec: float
    temperature: float
    colour_score: Optional[str] = None
    timestamp: datetime = datetime.utcnow()

class MilkReadingCreate(MilkReadingBase):
    pass

class MilkReadingResponse(MilkReadingBase):
    id: int
    class Config:
        from_attributes = True

class CollarReadingBase(BaseModel):
    collar_id: str
    activity_level: str
    rumination_minutes: float
    body_temperature: float
    timestamp: datetime = datetime.utcnow()

class CollarReadingCreate(CollarReadingBase):
    pass

class CollarReadingResponse(CollarReadingBase):
    id: int
    class Config:
        from_attributes = True

class LabRecordBase(BaseModel):
    cow_id: str
    scc: int
    ph: float
    pathogen: Optional[str] = None
    timestamp: datetime = datetime.utcnow()

class LabRecordCreate(LabRecordBase):
    pass

class LabRecordResponse(LabRecordBase):
    id: int
    recorded_by: int
    class Config:
        from_attributes = True
        
class CurrentStatePredictionRequest(BaseModel):
    milk_temperature: float
    milk_conductivity: float
    milk_yield: float

class AIPredictionResponse(BaseModel):
    id: int
    cow_id: str
    prediction_type: str = "current_state_classification"
    predicted_class: int
    mastitis_probability: float
    model_name: str
    features_used: List[str]
    warning: str = "Baseline classification only; not a 7–14 day forecast or medical diagnosis."
    timestamp: datetime
    class Config:
        from_attributes = True

class ManualDataBase(BaseModel):
    type: str
    notes: Optional[str] = None
    timestamp: datetime = datetime.utcnow()

class ManualDataCreate(ManualDataBase):
    pass

class ManualDataResponse(ManualDataBase):
    id: int
    cow_id: str
    recorded_by: int
    class Config:
        from_attributes = True

class ManualSensorReadingCreate(BaseModel):
    body_temperature: Optional[float] = None
    udder_temperature: Optional[float] = None
    milk_temperature: Optional[float] = None
    milk_conductivity: Optional[float] = None
    activity_level: Optional[float] = None
    milk_yield: Optional[float] = None
    notes: Optional[str] = None

class FeedbackBase(BaseModel):
    prediction_id: int
    accuracy_rating: int
    actual_outcome: Optional[str] = None
    comments: Optional[str] = None
    timestamp: datetime = datetime.utcnow()

class FeedbackCreate(FeedbackBase):
    pass

class FeedbackResponse(FeedbackBase):
    id: int
    user_id: int
    class Config:
        from_attributes = True
