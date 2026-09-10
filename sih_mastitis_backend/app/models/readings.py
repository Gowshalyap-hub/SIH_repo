from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base
from datetime import datetime

class MilkReading(Base):
    __tablename__ = "milk_readings"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String, ForeignKey("milking_sessions.id"), nullable=False)
    yield_volume = Column(Float, nullable=False)
    ec = Column(Float, nullable=False)
    temperature = Column(Float, nullable=False)
    colour_score = Column(String, nullable=True)
    spectral_f1 = Column(Float, nullable=True)
    spectral_f2 = Column(Float, nullable=True)
    spectral_f3 = Column(Float, nullable=True)
    spectral_f4 = Column(Float, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)

    session = relationship("MilkingSession", back_populates="readings")

class CollarReading(Base):
    __tablename__ = "collar_readings"

    id = Column(Integer, primary_key=True, index=True)
    collar_id = Column(String, ForeignKey("collar_devices.id"), nullable=False)
    activity_level = Column(String, nullable=False) # e.g. low, normal, high
    acceleration_magnitude = Column(Float, nullable=True)
    rumination_minutes = Column(Float, nullable=False)
    rumination_sound_level = Column(Float, nullable=True)
    body_temperature = Column(Float, nullable=False)
    humidity = Column(Float, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)

class TemperatureReading(Base):
    __tablename__ = "temperature_readings"

    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String, nullable=False)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=True)
    temperature = Column(Float, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
