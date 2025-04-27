from fastapi import APIRouter, Depends
from fastapi import  HTTPException, status
from fastapi.params import Header
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import jwt, JWTError
from datetime import timedelta, datetime, timezone
from passlib.context import CryptContext
from passlib.exc import InvalidTokenError
from sqlalchemy.orm import Session
from app.core.config import settings
from app.core.response_model import APIResponse
from app.models.user import User, DeletedUser
from app.schemas.user import UserCreate, UpdateProfileImage, UserResponse, UserUpdate
from app.database.get_db import get_db

authRouter = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def clean_user(user: User):
    res = UserResponse.model_validate(user)
    return res.model_dump()

async def get_user_by_email(
        email: str,
        db : Session
) -> User | None:
    user = db.query(User).filter(
        User.email == email
    ).first()

    if not user:
        return None

    return user

async def create_user(
        user: UserCreate,
        db: Session = Depends(get_db),
):
    try:
        hashed_password = pwd_context.hash(user.password)
        db_user = User(
            name=user.name,
            email=user.email,
            password=hashed_password,
            dob=user.dob,
            height=user.height,
            weight=user.weight,
            created_at=datetime.now(),
            profile_image=None,
        )

        db.add(db_user)
        db.commit()
        db.refresh(db_user)

        user_response = clean_user(db_user)

        return APIResponse.success_response(
            data= user_response,
            message="User registered successfully."
        )
    except Exception as e:
        return APIResponse.error_response(
            message="Failed to register user",
            error=str(e),
        )

async def authenticate_user(db: Session,email: str, password: str):
    user = await get_user_by_email(email,db=db)
    if not user:
        return False
    if not pwd_context.verify(password, user.password):
        return False
    return user


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=30)
    to_encode.update({
        "exp": expire
    })
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGO)
    return encoded_jwt


def verify_token_fun(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGO])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=403, detail="Token is invalid or expired")
        return payload
    except JWTError:
        raise HTTPException(status_code=403, detail="Token is invalid or expired")


def decode_token(token: str):
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGO])
        return payload  # typically contains user_id or email
    except JWTError:
        return None


async def get_current_user(
        db:Session,
        authorization: str,
        error_exception: HTTPException,
):
    token = authorization
    decoded = decode_token(token)

    if not decoded or "sub" not in decoded:
        raise error_exception

    user = await get_user_by_email(email=decoded["sub"],db=db)

    if not user:
        raise error_exception

    return user




credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_auth_user(
        authorization: str = Header(...),
        db: Session = Depends(get_db),
):
    if not authorization.startswith("Bearer "):
        raise credentials_exception
    token = authorization.split(" ")[1]
    if not token:
        raise credentials_exception
    try:
        user = await get_current_user(
            authorization=token,
            error_exception=credentials_exception,
            db= db,
        )
        if not user:
            raise credentials_exception
        else:
            return clean_user(user)

    except InvalidTokenError:
        raise credentials_exception


@authRouter.get("/me")
async def get_me(current_user: dict = Depends(get_auth_user)):
    if current_user:
        return APIResponse.success_response(
            data=current_user,
            message="User fetched successfully!"
        )
    else:
        return APIResponse.error_response()


@authRouter.post("/register")
async def register(user: UserCreate,
                   db: Session = Depends(get_db)):

    check_user = await get_user_by_email(
        email=user.email.__str__(),
        db=db
    )

    if check_user:
        return APIResponse.error_response(
            message="You are already a part of better days please continue to login",
        )

    return await create_user(user=user,db=db)


@authRouter.post("/token_auth")
async def token_auth(
        form_data: OAuth2PasswordRequestForm = Depends(),
        db: Session = Depends(get_db)
):
    user = await authenticate_user(
        email=form_data.username,
        password=form_data.password,
        db=db,
    )
    if not user:
        return APIResponse.error_response(message="Incorrect email or password")
    minutes = settings.ACCESS_TOKEN_EXPIRE_MINUTES
    access_token_expire = timedelta(minutes=minutes)
    access_token = create_access_token(
        data={
            "sub": form_data.username
        },
        expires_delta=access_token_expire
    )

    return APIResponse.success_response(data={
        "access_token": access_token,
        "token_type": "Bearer",
        "user_data": clean_user(user)
    }, )


@authRouter.get("/verify_token/{token}")
async def verify_token(token: str):
    verify_token_fun(token=token)
    return APIResponse.success_response(
        message="Token is valid",
    )


@authRouter.patch("/users/{user_id}/profile-image")
async def update_profile_image(
        user_id: str,
        update: UpdateProfileImage,
        db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.profile_image = update.profile_image
    db.commit()
    db.refresh(user)

    if user:
        return {"message": "Profile image updated successfully"}

    raise HTTPException(status_code=404, detail="User not found")


@authRouter.patch("/users/{user_id}/update-profile")
async def update_profile(
        user_id: str,
        update: UserUpdate,
        db: Session = Depends(get_db),
):
    db_user = db.query(User).filter(User.id == user_id).first()

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    db_user.profile_image = update.profile_image
    db_user.name = update.name
    db_user.weight = update.weight
    db_user.height = update.height
    db_user.dob = update.dob

    db.commit()
    db.refresh(db_user)

    if db_user:
        return APIResponse.success_response(
            message="Profile image updated successfully",
        )

    raise HTTPException(status_code=404, detail="User not found")


@authRouter.delete("/users/{user_id}/delete")
async def delete_account(
        reason: str,
        current_user: User = Depends(get_auth_user),  # Changed to User type
        db: Session = Depends(get_db)
):
    if not current_user:
        raise credentials_exception

    if not reason:
        return APIResponse.error_response(
            message="Delete account reason is mandatory."
        )

    try:
        user_to_delete = db.query(User).filter(User.id == current_user.id).first()

        if not user_to_delete:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        deleted_user_record = {
            "id": user_to_delete.id,
            "email": user_to_delete.email,
            "reason": reason,
            "data": {
                "name": user_to_delete.name,
                "email": user_to_delete.email,
                "dob": user_to_delete.dob.isoformat() if user_to_delete.dob else None,
                "height": user_to_delete.height,
                "weight": user_to_delete.weight,
                "created_at": user_to_delete.created_at.isoformat()
            }
        }

        db.delete(user_to_delete)

        db.add(DeletedUser(
            original_id=user_to_delete.id,
            email=user_to_delete.email,
            reason=reason,
            user_data=deleted_user_record["data"]
        ))

        db.commit()

        return APIResponse.success_response(
            message="Account deleted successfully!",
            data={"deleted_user": deleted_user_record}
        )

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Error deleting account: {str(e)}"
        )
