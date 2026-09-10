from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class MilkingSession(Base):
    __tablename__ = "milking_sessions"

    id = Column(String, primary_key=True, index=True)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=False)
    smart_cup_id = Column(String, ForeignKey("smart_cups.id"), nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)

    cow = relationship("Cow", back_populates="sessions")
    smart_cup = relationship("SmartCup")
    readings = relationship("MilkReading", back_populates="session")
