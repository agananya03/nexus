import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base

class Message(Base):
    __tablename__ = "messages"

    msg_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content = Column(String, nullable=False)
    sent_at = Column(DateTime, default=datetime.utcnow)
    group_id = Column(UUID(as_uuid=True), ForeignKey("study_groups.group_id"))
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id"))
