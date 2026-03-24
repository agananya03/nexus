from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

# ── Doubt ────────────────────────────────────────────────────────────────────

class DoubtCreate(BaseModel):
    question: str
    description: Optional[str] = None
    subject: str
    semester: int
    tags: List[str] = []

class DoubtResponse(BaseModel):
    doubt_id: str
    question: str
    subject: str
    semester: int
    tags: List[str]
    asked_by: str
    is_resolved: bool
    answer_count: int
    created_at: datetime

    class Config:
        from_attributes = True

# ── Answer ───────────────────────────────────────────────────────────────────

class AnswerCreate(BaseModel):
    content: str

class AnswerResponse(BaseModel):
    answer_id: str
    content: str
    upvotes: int
    doubt_id: str
    answered_by: str
    answered_by_name: str
    is_accepted: bool
    created_at: datetime
    user_has_upvoted: bool

    class Config:
        from_attributes = True

# ── Resolve ──────────────────────────────────────────────────────────────────

class ResolveRequest(BaseModel):
    accepted_answer_id: Optional[str] = None
