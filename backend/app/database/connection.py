from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

DB_URI = settings.DB_URI

engine = create_engine(DB_URI)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit = False,
)

Base = declarative_base()