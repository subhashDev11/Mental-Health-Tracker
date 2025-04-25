from sqlalchemy import Column, Integer, String, JSON, DateTime

from app.database.connection import Base


class Journal(Base):
    __tablename__ = "journals"

    id= Column(Integer, primary_key=True, index=True,nullable=False)
    content= Column(String,nullable=True)
    title= Column(String,nullable=True)
    created_by= Column(String,nullable=False)
    tags = Column(JSON,nullable=True)
    created_at= Column(DateTime,nullable=False)

    class Config:
        from_attributes = True