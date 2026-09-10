from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base
from datetime import datetime

class ManualData(Base):
    __tablename__ = "manual_data"

    id = Column(Integer, primary_key=True, index=True)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=False)
    type = Column(String, nullable=False)
    notes = Column(String, nullable=True)
    recorded_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    cow = relationship("Cow", back_populates="manual_data")

class LabRecord(Base):
    __tablename__ = "lab_records"

    id = Column(Integer, primary_key=True, index=True)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=False)
    scc = Column(Integer, nullable=False)
    ph = Column(Float, nullable=False)
    pathogen = Column(String, nullable=True)
    recorded_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    cow = relationship("Cow", back_populates="lab_records")
