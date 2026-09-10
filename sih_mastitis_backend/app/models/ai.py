from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base
from datetime import datetime

class AIPrediction(Base):
    __tablename__ = "ai_predictions"

    id = Column(Integer, primary_key=True, index=True)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=False)
    prediction_type = Column(String, default="current_state_classification")
    predicted_class = Column(Integer, nullable=False)
    mastitis_probability = Column(Float, nullable=False)
    model_name = Column(String, nullable=False)
    features_used = Column(String, nullable=True) # comma separated
    timestamp = Column(DateTime, default=datetime.utcnow)

    cow = relationship("Cow", back_populates="predictions")

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    cow_id = Column(String, ForeignKey("cows.id"), nullable=False)
    message = Column(String, nullable=False)
    is_read = Column(Integer, default=0) # SQLite/Postgres boolean compat
    timestamp = Column(DateTime, default=datetime.utcnow)

    cow = relationship("Cow", back_populates="alerts")

class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(Integer, primary_key=True, index=True)
    prediction_id = Column(Integer, ForeignKey("ai_predictions.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    accuracy_rating = Column(Integer, nullable=False)
    actual_outcome = Column(String, nullable=True)
    comments = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
