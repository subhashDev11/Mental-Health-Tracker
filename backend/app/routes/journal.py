from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.orm import Session

from app.core.response_model import APIResponse
from app.database.get_db import get_db
from app.models.user import User
from app.routes.auth import get_auth_user, credentials_exception
from app.schemas.journal import JournalCreate, JournalOut
from app.models.journal import Journal

journalRouter = APIRouter()


@journalRouter.post("/create")
async def create_journal(
        journal: JournalCreate,
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    try:
        db_journal = Journal(
            content=journal.content,
            title=journal.title,
            created_by=current_user['id'],
            created_at=datetime.now(),
            tags=journal.tags
        )

        db.add(db_journal)
        db.commit()
        db.refresh(db_journal)

        journal_out = JournalOut(
            title=db_journal.title,
            content=db_journal.content,
            tags=db_journal.tags,
            created_at=db_journal.created_at,
            created_by={
                "id": db_journal.created_by,
                "name": current_user['name'],
            },
            id=str(db_journal.id),
        )

        return APIResponse.success_response(
            data=journal_out.model_dump(),
            message="Journal created successfully",
        )

    except Exception as e:
        return APIResponse.error_response(error=str(e))


@journalRouter.get("/getById/{journal_id}")
async def get_journal_by_id(
        journal_id: str,
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not journal_id:
        raise HTTPException(status_code=400, detail="Invalid journal ID")

    if not current_user:
        raise credentials_exception

    db_journal = db.query(Journal).filter(
        Journal.id == journal_id
    ).first()

    if db_journal is None:
        raise HTTPException(
            status_code=404,
            detail="Journal not found"
        )

    journal_out = JournalOut(
        title=db_journal.title,
        content=db_journal.content,
        tags=db_journal.tags,
        created_at=db_journal.created_at,
        created_by={
            "id": db_journal.created_by,
            "name": current_user['name'],
        },
        id=str(db_journal.id),
    )

    return APIResponse.success_response(
        data=journal_out.model_dump(),
        message="Journal found"
    )


@journalRouter.get("/getAllJournals")
async def get_all_journals(
        skip: int = Query(0, ge=0),
        limit: int = Query(10, ge=1, le=100),
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    try:

        stmt = (
            select(
                Journal,
                User.id.label("user_id"),
                User.name.label("user_name")
            )
            .join(User, Journal.created_by == User.id, isouter=True)
            .order_by(Journal.created_at.desc())
            .offset(skip)
            .limit(limit)
        )

        result = db.execute(stmt)
        journal_list = []

        for journal, user_id, user_name in result:
            journal_dict = {
                "id": str(journal.id),
                "title": journal.title,
                "content": journal.content,
                "created_at": journal.created_at,
                "tags": journal.tags,
                # "updated_at": journal.updated_at,
                "created_by": {
                    "id": str(user_id),
                    "name": user_name
                } if user_id else None
            }

            d = JournalOut(**journal_dict).model_dump(by_alias=True)
            journal_list.append(d)

        total = db.scalar(select(func.count()).select_from(Journal))

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
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db),
):
    try:
        if not journal_id:
            raise HTTPException(status_code=400, detail="Invalid journal ID")

        if not current_user:
            raise credentials_exception

        journal_to_delete = db.query(Journal).filter(Journal.id == journal_id).first()

        if not journal_to_delete:
            raise HTTPException(
                status_code=404,
                detail="Journal not found"
            )

        db.delete(journal_to_delete)
        db.commit()

        return APIResponse.success_response(
            message="Journal deleted successfully!"
        )
    except Exception as e:
        return APIResponse.error_response(
            message="Error on deletion of journal",
            error=str(e)
        )


@journalRouter.get("/getJournalsCreatedByMe")
async def get_journals_created_by_me(
        skip: int = Query(0, ge=0),
        limit: int = Query(10, ge=1, le=100),
        current_user: dict = Depends(get_auth_user),
        db: Session = Depends(get_db),
):
    if not current_user:
        raise credentials_exception

    if not current_user['id']:
        raise credentials_exception

    stmt = (
        select(
            Journal,
            User.id.label("user_id"),
            User.name.label("user_name")
        )
        .join(User, Journal.created_by == User.id, isouter=True)
        .filter(Journal.created_by==current_user['id'])
        .order_by(Journal.created_at.desc())
        .offset(skip)
        .limit(limit)
    )

    result = db.execute(stmt)

    journal_list = list()

    for journal, user_id, user_name in result:
        journal_dict = {
            "id": str(journal.id),
            "title": journal.title,
            "content": journal.content,
            "created_at": journal.created_at,
            "tags": journal.tags,
            # "updated_at": journal.updated_at,
            "created_by": {
                "id": str(user_id),
                "name": user_name
            } if user_id else None
        }

        d = JournalOut(**journal_dict).model_dump(by_alias=True)
        journal_list.append(d)

    total = db.scalar(select(func.count()).select_from(Journal).filter(
        Journal.created_by == current_user['id']
    ))

    return APIResponse.success_response(
        data={
            "skip": skip,
            "total_count": total,
            "limit": limit,
            "journals": journal_list,
        }
    )
