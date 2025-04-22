from bson import ObjectId
from datetime import datetime


def journal_dict(journal) -> dict:
    return {
        "id": str(journal["_id"]),
        "user_id": str(journal["user_id"]),
        "content": journal["content"],
        "tags": journal.get("tags", []),
        "created_at": journal["created_at"],
        "title": journal["title"],
        "create_by": journal['create_by'],
    }
