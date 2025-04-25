import shutil
from functools import lru_cache
from pathlib import Path

from fastapi import FastAPI, Request, Form, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
from fastapi.params import Depends
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from starlette.staticfiles import StaticFiles

from app.core import config
from app.core.config import settings
from app.core.response_model import APIResponse
from app.database.get_db import get_db
from app.database.connection import engine, Base
from app.models.user import User
from app.routes.journal import journalRouter
# from app.routes.mood import moodRouter
from app.routes.auth import authRouter
from app.routes.daily_quote import dailyQuoteRouter

app = FastAPI()

Base.metadata.create_all(bind=engine)



def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="Mental Health Tracker",
        version="1.0.0",
        description="Mental Health Tracker backend",
        routes=app.routes,
    )
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT"
        }
    }
    openapi_schema["security"] = [{"BearerAuth": []}]
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


@lru_cache
def get_settings():
    return config.Settings()


origins = [
    "https://localhost:3000",

]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(
    router=authRouter,
    prefix="/api/auth"
)

# app.include_router(
#     router=moodRouter,
#     prefix="/api/mood"
# )

app.include_router(
    router=journalRouter,
    prefix="/api/journal"
)

app.include_router(
    router=dailyQuoteRouter,
    prefix="/api/daily_quote"
)


@app.exception_handler(SQLAlchemyError)
async def pymongo_exception_handler(request: Request, exc: SQLAlchemyError):
    return JSONResponse(
        status_code=500,
        content=APIResponse.error_response(
            error="Database error: " + str(exc),
        ).dict(),
    )


BASE_UPLOAD_DIR = Path("uploads/images")


app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.post("/api/upload")
async def upload_file(
        unique_id: str = Form(...),
        file: UploadFile = File(...),
        db: Session = Depends(get_db)
):
    try:
        if not file.content_type.startswith(("image/", "application/")):
            raise HTTPException(status_code=400, detail="Invalid file type.")

        user_dir = BASE_UPLOAD_DIR / unique_id
        user_dir.mkdir(parents=True, exist_ok=True)

        save_path = user_dir / file.filename

        with open(save_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        download_url = f"{settings.LAUNCH_URL}uploads/images/{unique_id}/{file.filename}"

        try:
            if unique_id:
                user = db.query(User).filter(User.id == unique_id).first()

                if not user:
                    raise HTTPException(status_code=404, detail="User not found")

                user.profile_image = download_url
                db.commit()
                db.refresh(user)
        except Exception as e:
            print(e)


        data: dict = {
            "message": "File uploaded successfully",
            "unique_id": unique_id,
            "file": file.filename,
            "download_url": download_url
        }

        return APIResponse.success_response(
            data=data
        )
    except Exception as e:
        return APIResponse.error_response(
            error=str(e),
        )
