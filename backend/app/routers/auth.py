from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.schemas.user_schema import UserRegister, UserLogin, UserResponse, TokenResponse, UserUpdate
from app.core.auth import hash_password, verify_password, create_access_token, get_current_user
from pydantic import BaseModel
from google.oauth2 import id_token
from google.auth.transport import requests

router = APIRouter()

@router.post("/register", response_model=TokenResponse)
def register(user_data: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    new_user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        college=user_data.college,
        branch=user_data.branch,
        year=user_data.year,
        semester=user_data.semester
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    token = create_access_token({"user_id": str(new_user.user_id)})
    return TokenResponse(access_token=token)

@router.post("/login", response_model=TokenResponse)
def login(user_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_data.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    if user.password_hash is None or not verify_password(user_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    token = create_access_token({"user_id": str(user.user_id)})
    return TokenResponse(access_token=token)

class GoogleAuth(BaseModel):
    id_token: str

@router.post("/google", response_model=TokenResponse)
def google_auth(auth_data: GoogleAuth, db: Session = Depends(get_db)):
    try:
        idinfo = id_token.verify_oauth2_token(auth_data.id_token, requests.Request())
        email = idinfo.get("email")
        if not email:
            raise HTTPException(status_code=400, detail="Invalid token")
            
        user = db.query(User).filter(User.email == email).first()
        if not user:
            name = idinfo.get("name", "Google User")
            user = User(name=name, email=email)
            db.add(user)
            db.commit()
            db.refresh(user)
            
        token = create_access_token({"user_id": str(user.user_id)})
        return TokenResponse(access_token=token)
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid Google token")

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: str, update_data: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if str(current_user.user_id) != user_id:
        raise HTTPException(status_code=403, detail="Not authorized to update this profile")
        
    if update_data.college is not None:
        current_user.college = update_data.college
    if update_data.branch is not None:
        current_user.branch = update_data.branch
    if update_data.year is not None:
        current_user.year = update_data.year
    if update_data.semester is not None:
        current_user.semester = update_data.semester
        
    db.commit()
    db.refresh(current_user)
    return current_user
