from sqlalchemy import Column, String
from app.db.database import Base

class SmartCup(Base):
    __tablename__ = "smart_cups"

    id = Column(String, primary_key=True, index=True)
    mac_address = Column(String, unique=True, index=True, nullable=False)
    status = Column(String, nullable=False, default="active")
