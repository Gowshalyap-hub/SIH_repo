from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False) # FARMER, VETERINARIAN, COOPERATIVE, ADMIN
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=True)
    phone = Column(String, nullable=True)

    farm = relationship("Farm", back_populates="users", foreign_keys=[farm_id])
