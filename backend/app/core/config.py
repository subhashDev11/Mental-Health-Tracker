import os
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Path to the .env file
ENV_PATH = BASE_DIR / ".env"

DOTENV = os.path.join(os.path.dirname(__file__), ENV_PATH)


class Settings(BaseSettings):
    DB_URI: str
    SECRET_KEY: str
    ALGO: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    APP_NAME: str
    DEBUG: str
    LAUNCH_URL: str

    model_config = SettingsConfigDict(env_file=DOTENV)

settings = Settings()