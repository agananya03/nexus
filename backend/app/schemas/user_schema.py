from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID

class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    college: Optional[str] = None
    branch: Optional[str] = None
    year: Optional[int] = None
    semester: Optional[int] = None

class UserLogin(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    user_id: UUID
    name: str
    email: str
    college: Optional[str] = None
    branch: Optional[str] = None
    year: Optional[int] = None
    semester: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True
        orm_mode = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserUpdate(BaseModel):
    college: Optional[str] = None
    branch: Optional[str] = None
    year: Optional[int] = None
    semester: Optional[int] = None
