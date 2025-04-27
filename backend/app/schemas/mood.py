from pydantic import BaseModel, Field, model_serializer
from datetime import datetime
from typing import Optional


class MoodCreate(BaseModel):
    mood: int  # or str if you're using emojis
    note: Optional[str] = None


class MoodOut(BaseModel):
    id: str
    user_id: str = None
    mood: int
    note: Optional[str] = None
    created_at: datetime = None

    @model_serializer(mode="plain")
    def serialize_id_as_str(self) -> dict:
        data = self.__dict__.copy()
        data["id"] = str(self.id)
        return data