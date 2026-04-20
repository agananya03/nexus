from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID

class NoteCreate(BaseModel):
    title: str
    subject: str
    semester: int
    branch: Optional[str] = None

class NoteResponse(BaseModel):
    note_id: UUID
    title: str
    subject: str
    semester: int
    branch: Optional[str] = None
    file_url: str
    uploader_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
        orm_mode = True
