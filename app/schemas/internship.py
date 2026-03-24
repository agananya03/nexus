from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class InternshipCreate(BaseModel):
    company: str
    role: str
    location: str
    stipend: str
    domain: str
    deadline: datetime
    apply_link: str

class InternshipOut(BaseModel):
    listing_id: str
    company: str
    role: str
    location: str
    stipend: str
    domain: str
    deadline: datetime
    apply_link: str
    posted_by: str
    created_at: datetime

    class Config:
        from_attributes = True
