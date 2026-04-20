import uuid
from datetime import datetime
from sqlalchemy import Column, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base

class GroupMembership(Base):
    __tablename__ = "group_memberships"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    group_id = Column(UUID(as_uuid=True), ForeignKey("study_groups.group_id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id"))
    joined_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint('group_id', 'user_id', name='uq_group_user'),
    )
