from typing import Optional, Any
from pydantic import BaseModel

class APIResponse(BaseModel):
    success: bool
    message: str
    error: Optional[Any] = None
    data: Optional[dict] = None

    @classmethod
    def success_response(cls, message: str = "Success", data: Optional[dict] = None):
        return cls(success=True, message=message, data=data)

    @classmethod
    def error_response(cls, message: str = "Something went wrong", error: Optional[Any] = None):
        return cls(success=False, message=message, error=error)