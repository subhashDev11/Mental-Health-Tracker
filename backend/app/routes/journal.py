from datetime import datetime

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query
from pymongo.errors import DuplicateKeyError, OperationFailure, WriteError, WriteConcernError

from app.core.response_model import APIResponse
from app.database.connection import journal_collection
from app.routes.auth import get_auth_user, credentials_exception
from app.schemas.journal import JournalCreate, JournalOut

journalRouter = APIRouter()


@journalRouter.post("/create")
async def create_journal(
        journal: JournalCreate,
        current_user: dict = Depends(get_auth_user),
):
    if not current_user:
        raise credentials_exception

    try:
        dump = journal.model_dump()
        dump['created_by'] = ObjectId(current_user['id'])
        dump["created_at"] = datetime.now()

        result = await journal_collection.insert_one(dump)
        created_journal = await journal_collection.find_one({
            "_id": result.inserted_id,
        })

        created_journal['_id'] = str(created_journal['_id'])

        return APIResponse.success_response(
            data=JournalOut(**created_journal).model_dump(
                by_alias=True
            ),
            message="Journal created successfully",
        )

    except DuplicateKeyError:
        return APIResponse.error_response(error="Duplicate entry detected.")
    except (OperationFailure, WriteError, WriteConcernError):
        return APIResponse.error_response(error="Database operation failed.")
    except Exception as e:
        return APIResponse.error_response(error=str(e))


@journalRouter.get("/getById/{journal_id}")
async def get_journal_by_id(
        journal_id: str,
        current_user: dict = Depends(get_auth_user)
):
    if not ObjectId.is_valid(journal_id):
        raise HTTPException(status_code=400, detail="Invalid journal ID")

    if not current_user:
        raise credentials_exception

    if not journal_id:
        return APIResponse.error_response(
            message="Please provide the journal id",
        )

    result = await journal_collection.find_one({
        "_id": ObjectId(journal_id),
    })

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Journal not found"
        )
    result["_id"] = str(result["_id"])

    return APIResponse.success_response(
        data=JournalOut(**result).model_dump(
            by_alias=True
        ),
        message="Journal found"
    )


@journalRouter.get("/getAllJournals")
async def get_all_journals(
        skip: int = Query(0, ge=0),
        limit: int = Query(10, ge=1, le=100),
        current_user: dict = Depends(get_auth_user)
):
    if not current_user:
        raise credentials_exception

    try:

        pipeline = [
            {"$sort": {"created_at": -1}},
            {"$skip": skip},
            {"$limit": limit},
            {
                "$lookup": {
                    "from": "users",
                    "localField": "created_by",
                    "foreignField": "_id",
                    "as": "user_info"
                }
            },
            {
                "$unwind": {
                    "path": "$user_info",
                    "preserveNullAndEmptyArrays": True
                }
            }
        ]

        cursor = journal_collection.aggregate(pipeline)
        journal_list = list()

        async for i in cursor:
            i["_id"] = str(i['_id'])
            i["created_by"] = {
                "id": str(i["user_info"]["_id"]),
                "name": i["user_info"]["name"]
            } if i.get("user_info") else None

            i.pop("user_info", None)

            d = JournalOut(**i).model_dump(by_alias=True)
            journal_list.append(d)

        total = await journal_collection.count_documents({})

        return APIResponse.success_response(
            data={
                "skip": skip,
                "total_count": total,
                "limit": limit,
                "journals": journal_list,
            }
        )
    except Exception as e:
        return APIResponse.error_response(
            message="Failed to fetch journal",
            error=str(e)
        )


@journalRouter.delete("/delete/{journal_id}")
async def delete_journal_by_id(
        journal_id: str,
        current_user: dict = Depends(get_auth_user)
):
    if not ObjectId.is_valid(journal_id):
        raise HTTPException(status_code=400, detail="Invalid journal ID")

    if not current_user:
        raise credentials_exception
    result = await journal_collection.delete_one(
        {
            "_id": ObjectId(journal_id)
        }
    )

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Journal not found"
        )
    return APIResponse.success_response(
        message="Journal deleted successfully!"
    )


@journalRouter.get("/getJournalsCreatedByMe")
async def get_journals_created_by_me(
        skip: int = Query(0, ge=0),
        limit: int = Query(10, ge=1, le=100),
        current_user: dict = Depends(get_auth_user)
):
    if not current_user:
        raise credentials_exception

    if not current_user['id']:
        raise credentials_exception

    cursor = journal_collection.find({
        "created_by": current_user['id']
    }).sort("created_at", -1).skip(skip).limit(limit)


    journal_list = list()

    async for i in cursor:
        i["_id"] = str(i['_id'])
        d = JournalOut(**i).model_dump(
            by_alias=False
        )
        journal_list.append(d)

    total = await journal_collection.count_documents({
        "created_by": current_user['id'],
    })

    return APIResponse.success_response(
        data={
            "skip": skip,
            "total_count": total,
            "limit": limit,
            "journals": journal_list,
        }
    )
