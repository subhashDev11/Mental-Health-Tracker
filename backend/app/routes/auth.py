from bson import ObjectId
from fastapi import APIRouter
from fastapi import Depends, HTTPException, status
from fastapi.params import Header
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import jwt, JWTError
from datetime import timedelta, datetime, timezone
from passlib.context import CryptContext
from passlib.exc import InvalidTokenError
from app.core.config import settings
from app.core.response_model import APIResponse
from app.database.connection import user_collection, mood_collection, deleted_user_collection
from app.models.user import user_dict, user_dict_with_hash
from app.schemas.user import UserCreate, UpdateProfileImage, UserUpdate

authRouter = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


async def get_user_by_email(email: str, with_hash: bool) -> dict | None:
    user = await user_collection.find_one({
        "email": email,
    })

    if not user:
        return None

    if with_hash:
        return user_dict_with_hash(user)
    else:
        return user_dict(user)


async def create_user(user: UserCreate):
    try:
        hashed_password = pwd_context.hash(user.password)
        db_user = user.model_dump()
        db_user['hashed_password'] = hashed_password
        db_user['created_at'] = datetime.now()
        db_user['profile_image'] = None
        await user_collection.insert_one(db_user)
        createdUser = await get_user_by_email(user.email.__str__(), with_hash=False)
        return APIResponse.success_response(
            data=createdUser,
            message="User registered successfully."
        )
    except Exception as e:
        return APIResponse.error_response(
            message="Failed to register user",
            error=e,
        )


async def authenticate_user(email: str, password: str):
    user = await get_user_by_email(email, with_hash=True)
    if not user:
        return False
    if not pwd_context.verify(password, user['hashed_password']):
        return False
    user.pop("hashed_password")
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


async def get_current_user(authorization: str, error_exception: HTTPException):
    token = authorization
    decoded = decode_token(token)

    if not decoded or "sub" not in decoded:
        raise error_exception
    query = {"email": decoded["sub"]}
    user = await user_collection.find_one(query)
    if not user:
        raise error_exception

    return user


def clean_user(user):
    return {
        "id": str(user["_id"]),
        "email": user.get("email"),
        "name": user.get("name"),
        "dob": user.get("dob"),
        "height": user.get("height"),
        "weight": user.get("weight"),
        "created_at": user.get("created_at"),
        "profile_image": user.get("profile_image")
    }


credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_auth_user(
        authorization: str = Header(...)
):
    if not authorization.startswith("Bearer "):
        raise credentials_exception

    token = authorization.split(" ")[1]

    if not token:
        raise credentials_exception

    try:
        user = await get_current_user(token, credentials_exception)
        if not user:
            raise credentials_exception
        else:
            # return APIResponse.success_response(
            #     data=clean_user(user),
            #     message="User fetched successfully!"
            # )
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
async def register(user: UserCreate):
    email = user.email

    db_user = await user_collection.find_one({
        "email": email,
    })
    if db_user:
        return APIResponse.error_response(
            message="You are already a part of better days please continue to login",
        )

    return await create_user(user=user)


@authRouter.post("/token_auth")
async def token_auth(form_data: OAuth2PasswordRequestForm = Depends(), ):
    user = await authenticate_user(email=form_data.username, password=form_data.password)
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
        "user_data": user
    }, )


@authRouter.get("/verify_token/{token}")
async def verify_token(token: str):
    verify_token_fun(token=token)
    return APIResponse.success_response(
        message="Token is valid",
    )


@authRouter.patch("/users/{user_id}/profile-image")
async def update_profile_image(user_id: str, update: UpdateProfileImage):
    try:
        obj_id = ObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid user ID")

    update_result = await user_collection.update_one(
        {"_id": obj_id},
        {"$set": {"profile_image": update.profile_image}}
    )

    if update_result.modified_count == 1:
        return {"message": "Profile image updated successfully"}

    raise HTTPException(status_code=404, detail="User not found")


@authRouter.patch("/users/{user_id}/update")
async def update_user_req(
        update_user: UserUpdate,
        current_user: dict = Depends(get_auth_user)
):
    try:
        if not current_user:
            raise credentials_exception

        if not current_user['id']:
            raise credentials_exception

        if not ObjectId(current_user['id']):
            raise credentials_exception

        if not update_user:
            raise HTTPException(status_code=400, detail="Invalid input")

        update_result = await user_collection.update_one(
            {"_id": ObjectId(current_user['id'])},
            {"$set": update_user.model_dump()}
        )

        if update_result.modified_count == 1:
            return APIResponse.success_response(
                message="Profile updated successfully",
            )
        else:
            raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=502,
            detail=str(e)
        )

@authRouter.delete("/users/{uid}/delete")
async def delete_account(
        reason : str,
        current_user: dict = Depends(
            get_auth_user
        )
):

  if not current_user:
      raise credentials_exception

  if not current_user['id']:
      raise credentials_exception

  if not reason:
      return APIResponse.error_response(
          message="Delete account reason is mandatory."
      )

  res = await user_collection.delete_one({
      "_id": ObjectId(current_user['id'])
  })

  if res.deleted_count==1:

      try:
          await deleted_user_collection.insert_one(
              {
                  "id": current_user['id'],
                  "email": current_user['email'],
                  "reason": reason,
                  "data": current_user,
              }
          )

      except Exception as e:
          print(e)

      return APIResponse.success_response(
          message="Account deleted successfully!"
      )
  else:
      raise HTTPException(
          status_code=404,
          detail="User not found"
      )


