from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class MoodCreate(BaseModel):
    mood: int  # or str if you're using emojis
    note: Optional[str] = None


class MoodOut(BaseModel):
    id: str = Field(..., alias="_id")
    user_id: str = None
    mood: int
    note: Optional[str] = None
    created_at: datetime = None
    create_at: datetime = None