from bson import ObjectId
from fastapi import APIRouter, HTTPException
from fastapi.params import Depends, Query
from datetime import datetime, timedelta

from pymongo.errors import DuplicateKeyError, OperationFailure, WriteError, WriteConcernError

from app.core.response_model import APIResponse
from app.database.connection import mood_collection
from app.routes.auth import get_auth_user, credentials_exception
from app.schemas.mood import MoodCreate, MoodOut

moodRouter = APIRouter()


@moodRouter.post("/addMood")
async def add_mood(
        mood: MoodCreate,
        current_user: dict = Depends(get_auth_user)
):
    try:
        if not current_user:
            raise credentials_exception
        if not MoodCreate:
            raise HTTPException(
                status_code=400,
                detail="Please provided the required args"
            )

        dict_mood: dict = mood.model_dump()
        dict_mood["user_id"] = current_user['id']
        dict_mood["created_at"] = datetime.now()

        result = await mood_collection.insert_one(dict_mood)

        if not result.inserted_id:
            return APIResponse.error_response(
                message="Something went wrong."
            )
        created_mood = await mood_collection.find_one({
            "_id": result.inserted_id,
        })

        created_mood["id"] = str(created_mood["_id"])
        del created_mood["_id"]

        mood_out = MoodOut(**created_mood)

        return APIResponse.success_response(
            data=mood_out.model_dump(),
            message="Mood added successfully"
        )

    except DuplicateKeyError:
        return APIResponse.error_response(error="Duplicate entry detected.")
    except (OperationFailure, WriteError, WriteConcernError):
        return APIResponse.error_response(error="Database operation failed.")
    except Exception as e:
        return APIResponse.error_response(error=str(e))


@moodRouter.get("/getMoodById/{mood_id}")
async def get_mood_by_id(
        mood_id: str,
        current_user: dict = Depends(
            get_auth_user
        )
):
    if not current_user:
        raise credentials_exception

    if not ObjectId.is_valid(mood_id):
        raise HTTPException(status_code=400, detail="Invalid mood Id")

    result = await mood_collection.find_one({
        "_id": ObjectId(mood_id),
    })

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Mood not found"
        )

    result["id"] = str(result["_id"])

    mood_out = MoodOut(**result)

    return APIResponse.success_response(
        data=mood_out.model_dump(),
        message="Success"
    )


@moodRouter.get("/fetchMoods")
async def get_moods(
        skip: int = Query(0, le=0, ),
        limit: int = Query(100, le=100, me=100),
        current_user: dict = Depends(get_auth_user)
):
    if not current_user:
        raise credentials_exception
    result = mood_collection.find({}).limit(limit).skip(skip).sort("create_at", -1)

    moods = list()

    async for m in result:
        m['id'] = str(m['_id'])
        mood = MoodOut(**m).model_dump(
            by_alias=True
        )

        moods.append(
            mood
        )

    total = await mood_collection.count_documents({})

    return APIResponse.success_response(
        data={
            "limit": limit,
            "skip": skip,
            "moods": moods,
            "total": total,
        }
    )


@moodRouter.delete("/deleteById/{mood_id}")
async def delete_mood_by_id(
        mood_id: str,
        current_user: dict = Depends(get_auth_user)
):
    if not current_user:
        raise credentials_exception

    if not ObjectId.is_valid(mood_id):
        raise HTTPException(status_code=400, detail="Invalid mood Id")

    deleted_res = await mood_collection.delete_one(
        {
            "_id": ObjectId(mood_id)
        }
    )

    if deleted_res.deleted_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Journal not found"
        )

    return APIResponse.success_response(
        message="Mood deleted successfully!"
    )


@moodRouter.get("/moods_added_by_me")
async def get_moods_added_by_me(
        skip:int = Query(
            0,le=0
        ),
        limit: int = Query(
            100,le=100, ge=100,
        ),
        current_user: dict = Depends(get_auth_user)
):
    try:
        if not current_user:
            raise credentials_exception
        if not current_user['id']:
            raise credentials_exception

        cursors = mood_collection.find({
            "user_id": current_user['id']
        }).limit(limit).skip(skip)

        moods = list()

        async for c in cursors:
            c["_id"] = str(c["_id"])

            mood = MoodOut(**c).model_dump(
                by_alias= False
            )
            moods.append(mood)

        total = await mood_collection.count_documents({
            "user_id": current_user['id'],
        })

        return APIResponse.success_response(
            data={
                "limit": limit,
                "skip": skip,
                "moods": moods,
                "total": total,
            }
        )

    except Exception as e:
        return APIResponse.error_response(
            error= str(e),
        )

def get_today_range():
    now = datetime.now()
    start = datetime(now.year, now.month, now.day)
    end = start + timedelta(days=1)
    return start, end

@moodRouter.get("/today_mood")
async def get_today_mood(
        current_user: dict = Depends(get_auth_user)
) :
    try:
        if not current_user:
            raise credentials_exception

        if not current_user['id']:
            raise credentials_exception

        start, end = get_today_range()
        mood = await mood_collection.find_one({
            "created_at": {"$gte": start, "$lt": end}
        })

        if mood is None:
            return APIResponse.error_response(
                message="Mood entry not found",
            )
        else:
            mood['_id'] = str(mood['_id'])
            return APIResponse.success_response(
                data=MoodOut(**mood).model_dump(
                    by_alias=False,
                )
            )

    except Exception as e:
        return APIResponse.error_response(
            message="Mood entry not found",
            error= str(e)
        )


