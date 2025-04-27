from fastapi import APIRouter, HTTPException
from fastapi.params import Depends, Query
from datetime import datetime, timedelta

from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.core.response_model import APIResponse
from app.database.get_db import get_db
from app.models.mood import Mood
from app.routes.auth import get_auth_user, credentials_exception
from app.schemas.mood import MoodCreate, MoodOut

moodRouter = APIRouter()


@moodRouter.post("/addMood")
async def add_mood(
        mood_create: MoodCreate,
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    try:
        if not current_user:
            raise credentials_exception

        if not MoodCreate:
            raise HTTPException(
                status_code=400,
                detail="Please provided the required args"
            )

        db_mood = Mood(
            note=mood_create.note,
            mood=mood_create.mood,
            user_id=current_user['id'],
            created_at=datetime.now(),
        )

        db.add(db_mood)
        db.commit()
        db.refresh(db_mood)

        if not db_mood.id:
            return APIResponse.error_response(
                message="Something went wrong."
            )

        mood_out = MoodOut(
            id = str(db_mood.id),
            user_id= db_mood.user_id,
            mood= db_mood.mood,
            note= db_mood.note,
            created_at=db_mood.created_at,
        )

        return APIResponse.success_response(
            data=mood_out.model_dump(),
            message="Mood added successfully"
        )

    except Exception as e:
        return APIResponse.error_response(error=str(e))


@moodRouter.get("/getMoodById/{mood_id}")
async def get_mood_by_id(
        mood_id: str,
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    if not mood_id:
        raise HTTPException(status_code=400, detail="Invalid mood Id")

    db_mood = db.query(Mood).filter(
        Mood.id == str(mood_id)
    ).first()



    if db_mood is None:
        raise HTTPException(
            status_code=404,
            detail="Mood not found"
        )

    mood_out = MoodOut(
        id=str(db_mood.id),
        user_id=db_mood.user_id,
        mood=db_mood.mood,
        note=db_mood.note,
        created_at=db_mood.created_at,
    )

    return APIResponse.success_response(
        data=mood_out.model_dump(),
        message="Success"
    )


@moodRouter.get("/fetchMoods")
async def get_moods(
        skip: int = Query(0, ge=0),
        limit: int = Query(100, le=100, ge=1),
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    moods_query = db.query(Mood).order_by(desc(Mood.created_at)).offset(skip).limit(limit)
    moods = moods_query.all()
    mood_list = []

    for mood in moods:
        mood_out = MoodOut(
            id=str(mood.id),
            user_id=mood.user_id,
            mood=mood.mood,
            note=mood.note,
            created_at=mood.created_at,
        )
        mood_list.append(mood_out.model_dump())

    total = db.query(Mood).count()

    return APIResponse.success_response(
        data={
            "limit": limit,
            "skip": skip,
            "moods": mood_list,
            "total": total,
        }
    )


@moodRouter.delete("/deleteById/{mood_id}")
async def delete_mood_by_id(
        mood_id: str,
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    if not mood_id:
        raise HTTPException(status_code=400, detail="Invalid mood Id")

    mood = db.query(Mood).filter(Mood.id == str(mood_id)).first()
    if not mood:
        raise HTTPException(
            status_code=404,
            detail="Mood not found"
        )

    db.delete(mood)
    db.commit()

    return APIResponse.success_response(
        message="Mood deleted successfully!"
    )


@moodRouter.get("/moods_added_by_me")
async def get_moods_added_by_me(
        skip: int = Query(0, ge=0),
        limit: int = Query(100, le=100, ge=1),
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    try:
        if not current_user:
            raise credentials_exception
        if not current_user['id']:
            raise credentials_exception

        moods_query = db.query(Mood).filter(
            Mood.user_id == str(current_user['id'])
        ).order_by(desc(Mood.created_at)).offset(skip).limit(limit)

        moods = moods_query.all()
        mood_list = []

        for mood in moods:
            mood_out = MoodOut(
                id=str(mood.id),
                user_id=mood.user_id,
                mood=mood.mood,
                note=mood.note,
                created_at=mood.created_at,
            )
            mood_list.append(mood_out.model_dump())

        total = db.query(Mood).filter(
            Mood.user_id == str(current_user['id'])
        ).count()

        return APIResponse.success_response(
            data={
                "limit": limit,
                "skip": skip,
                "moods": mood_list,
                "total": total,
            }
        )

    except Exception as e:
        return APIResponse.error_response(
            error=str(e),
        )


def get_today_range():
    now = datetime.now()
    start = datetime(now.year, now.month, now.day)
    end = start + timedelta(days=1)
    return start, end


@moodRouter.get("/today_mood")
async def get_today_mood(
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    try:
        if not current_user:
            raise credentials_exception

        if not current_user['id']:
            raise credentials_exception

        start, end = get_today_range()

        # Get today's mood for current user
        mood = db.query(Mood).filter(
            Mood.user_id == str(current_user['id']),
            Mood.created_at >= start,
            Mood.created_at < end
        ).first()

        if mood is None:
            return APIResponse.error_response(
                message="Mood entry not found",
            )
        else:

            mood_out = MoodOut(
                id=str(mood.id),
                user_id=mood.user_id,
                mood=mood.mood,
                note=mood.note,
                created_at=mood.created_at,
            )

            return APIResponse.success_response(
                data= mood_out.model_dump()
            )

    except Exception as e:
        return APIResponse.error_response(
            message="Mood entry not found",
            error=str(e)
        )