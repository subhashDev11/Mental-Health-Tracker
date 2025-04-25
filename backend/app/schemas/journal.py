from pydantic import BaseModel, json
from typing import List, Optional
from datetime import datetime



class JournalCreate(BaseModel):
    content: str
    title: str
    tags: Optional[List[str]] = []

    created_by: Optional[str] = None
    created_at: Optional[datetime] = None

    class Config:
        json_schema_extra = {
            "example": {
                "title": "Morning Thoughts",
                "content": "Woke up feeling energized and ready to start the day.",
                "tags": ["morning", "mood", "reflection"],
            }
        }


class JournalOut(BaseModel):
    id: str
    created_by: dict | None
    content: str

    title: str
    tags: list[str]
    created_at: Optional[datetime] = None

    class Config:
        validate_by_name = True
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
        }