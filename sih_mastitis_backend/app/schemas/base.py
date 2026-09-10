from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, date

class UserBase(BaseModel):
    name: Optional[str] = None
    email: EmailStr
    role: str
    farm_id: Optional[int] = None
    phone: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None

class UserResponse(UserBase):
    id: int
    class Config:
        from_attributes = True

class FarmBase(BaseModel):
    name: str
    location_lat: Optional[str] = None
    location_long: Optional[str] = None
    vet_name: Optional[str] = None
    vet_phone: Optional[str] = None
    vet_email: Optional[str] = None
    additional_details: Optional[str] = None

class FarmUpdate(BaseModel):
    name: Optional[str] = None
    location_lat: Optional[str] = None
    location_long: Optional[str] = None
    vet_name: Optional[str] = None
    vet_phone: Optional[str] = None
    vet_email: Optional[str] = None
    additional_details: Optional[str] = None

class FarmCreate(FarmBase):
    pass

class FarmResponse(FarmBase):
    id: int
    owner_id: Optional[int] = None
    class Config:
        from_attributes = True

class CowBase(BaseModel):
    id: str
    rfid: str
    breed: Optional[str] = None
    dob: Optional[date] = None

class CowCreate(CowBase):
    pass

class CowResponse(CowBase):
    farm_id: int
    collar_id: Optional[str] = None
    current_risk_level: Optional[str] = None
    last_milk_yield: Optional[float] = None
    last_updated: Optional[datetime] = None
    class Config:
        from_attributes = True
