from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/auth", tags=["auth"])

class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    college: Optional[str] = None
    branch: Optional[str] = None
    year: Optional[int] = None
    semester: Optional[int] = None

class GoogleAuthRequest(BaseModel):
    id_token: str

@router.post("/login")
def login(req: LoginRequest):
    return {"access_token": "fake-jwt-token"}

@router.post("/register")
def register(req: RegisterRequest):
    return {"access_token": "fake-jwt-token"}

@router.post("/google")
def google_login(req: GoogleAuthRequest):
    return {"access_token": "fake-jwt-token"}

@router.get("/me")
def get_me():
    return {
        "user_id": "demo-user-id",
        "name": "Demo User",
        "email": "demo@example.com",
        "college": "Example Tech",
        "branch": "CS",
        "year": 3,
        "semester": 6
    }
