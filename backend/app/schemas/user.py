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

    def to_map(self) -> dict:
        return self.model_dump()

    @classmethod
    def from_map(cls, data: dict):
        return cls(**data)


class UserUpdate(BaseModel):
    name: str | None
    dob: datetime | None
    height: float | None
    weight: float | None
    profile_image: str | None

    def to_map(self) -> dict:
        return self.model_dump()

    @classmethod
    def from_map(cls, data: dict):
        return cls(**data)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenData(BaseModel):
    email: Optional[str] = None


class UpdateProfileImage(BaseModel):
    profile_image: str

