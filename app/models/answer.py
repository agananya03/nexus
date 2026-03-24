import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from app.database import Base

class Answer(Base):
    __tablename__ = "answers"

    answer_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    content = Column(Text, nullable=False)
    doubt_id = Column(String(36), ForeignKey("doubts.doubt_id"), nullable=False)
    answered_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    is_accepted = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
