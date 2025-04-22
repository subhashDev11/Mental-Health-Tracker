from bson import ObjectId
from datetime import datetime


def mood_dict(mood) -> dict:
    return {
        "id": str(mood["_id"]),
        "user_id": str(mood["user_id"]),
        "mood": mood["mood"],
        "note": mood.get("note"),
        "create_at": mood["date"],
    }