from datetime import datetime

from sqlalchemy import Column, Integer, String, Float, DateTime, JSON
from app.database.connection import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
    name = Column(String, nullable=False)
    dob = Column(DateTime, nullable=True)
    height = Column(Float, nullable=True)
    weight = Column(Float, nullable=True)
    profile_image = Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False)

    class Config:
        from_attributes = True

class DeletedUser(Base):
    __tablename__ = "deleted_users"

    id = Column(Integer, primary_key=True)
    original_id = Column(Integer)
    email = Column(String)
    reason = Column(String)
    deleted_at = Column(DateTime, default=datetime.now)
    user_data = Column(JSON)