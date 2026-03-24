import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Text
from app.database import Base

class Doubt(Base):
    __tablename__ = "doubts"

    doubt_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    question = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    subject = Column(String, nullable=False)
    semester = Column(Integer, nullable=False)
    tags = Column(String, nullable=True)          # comma-separated
    asked_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    is_resolved = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
