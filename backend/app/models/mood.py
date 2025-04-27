from sqlalchemy import Column, Integer, String, DateTime

from app.database.connection import Base


# from bson import ObjectId
# from datetime import datetime
#
#
# def mood_dict(mood) -> dict:
#     return {
#         "id": str(mood["_id"]),
#         "user_id": str(mood["user_id"]),
#         "mood": mood["mood"],
#         "note": mood.get("note"),
#         "create_at": mood["date"],
#     }


class Mood(Base):
    __tablename__ = "moods"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True,nullable=False)
    user_id = Column(String,nullable=False)
    mood = Column(Integer, nullable=True)
    note = Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False)

    class Config:
        from_attributes = True
