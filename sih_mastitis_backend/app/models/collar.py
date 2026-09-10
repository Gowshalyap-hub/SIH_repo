from sqlalchemy import Column, String
from app.db.database import Base

class CollarDevice(Base):
    __tablename__ = "collar_devices"

    id = Column(String, primary_key=True, index=True)
    mac_address = Column(String, unique=True, index=True, nullable=False)
    status = Column(String, nullable=False, default="active")
