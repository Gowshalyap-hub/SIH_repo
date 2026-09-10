from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class Farm(Base):
    __tablename__ = "farms"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location_lat = Column(String, nullable=True)
    location_long = Column(String, nullable=True)
    owner_id = Column(Integer, ForeignKey("users.id"))
    vet_name = Column(String, nullable=True)
    vet_phone = Column(String, nullable=True)
    vet_email = Column(String, nullable=True)
    additional_details = Column(String, nullable=True)
    
    users = relationship("User", back_populates="farm", foreign_keys="User.farm_id")
    cows = relationship("Cow", back_populates="farm")
