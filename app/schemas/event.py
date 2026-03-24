from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class EventCreate(BaseModel):
    title: str
    description: str
    date: datetime
    venue: str
    organizer: str
    category: str
    rsvp_limit: int

class EventOut(BaseModel):
    event_id: str
    title: str
    description: str
    date: datetime
    venue: str
    organizer: str
    category: str
    rsvp_limit: int
    posted_by: str
    created_at: datetime
    rsvp_count: Optional[int] = 0

    class Config:
        from_attributes = True

class RSVPOut(BaseModel):
    rsvp_id: str
    event_id: str
    user_id: str
    rsvped_at: datetime

    class Config:
        from_attributes = True

class AttendeeOut(BaseModel):
    user_id: str
    name: str
    email: str
