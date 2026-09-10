from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class Cow(Base):
    __tablename__ = "cows"

    id = Column(String, primary_key=True, index=True)
    rfid = Column(String, unique=True, index=True, nullable=False)
    breed = Column(String, nullable=True)
    dob = Column(Date, nullable=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    collar_id = Column(String, ForeignKey("collar_devices.id"), nullable=True)

    farm = relationship("Farm", back_populates="cows")
    collar = relationship("CollarDevice")
    sessions = relationship("MilkingSession", back_populates="cow")
    manual_data = relationship("ManualData", back_populates="cow")
    lab_records = relationship("LabRecord", back_populates="cow")
    predictions = relationship("AIPrediction", back_populates="cow")
    alerts = relationship("Alert", back_populates="cow")
