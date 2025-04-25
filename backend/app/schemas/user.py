from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    dob: datetime
    height: float
    weight: float


class UserUpdate(BaseModel):
    name: Optional[str] = None
    dob: Optional[datetime] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    profile_image: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenData(BaseModel):
    email: Optional[str] = None


class UpdateProfileImage(BaseModel):
    profile_image: str

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    name: str
    dob: Optional[datetime]
    height: Optional[float]
    weight: Optional[float]
    profile_image: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True