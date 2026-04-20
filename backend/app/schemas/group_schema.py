from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID

class GroupCreate(BaseModel):
    name: str
    subject: str
    description: Optional[str] = None
    max_members: int = 50

class GroupResponse(BaseModel):
    group_id: UUID
    name: str
    subject: str
    description: Optional[str] = None
    max_members: int
    member_count: int = 0
    created_by: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class MessageResponse(BaseModel):
    msg_id: UUID
    content: str
    sent_at: datetime
    group_id: UUID
    sender_id: UUID
    sender_name: Optional[str] = None

    class Config:
        from_attributes = True
