import sys

from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import ConnectionFailure, ConfigurationError

from app.core.config import settings

try:
    MONGO_URI = settings.MONGO_URI

    client = AsyncIOMotorClient(MONGO_URI)
    db = client["mental_health_tracker"]

    user_collection = db["users"]
    mood_collection = db["mood"]
    journal_collection = db["journal"]
    deleted_user_collection = db["deleted_user"]

except (ConnectionFailure, ConfigurationError) as e:
    print(f"❌ Failed to connect to MongoDB: {e}")
    sys.exit(1)  # exit the app if DB connection fails