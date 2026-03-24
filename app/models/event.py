import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from app.database import Base

class Event(Base):
    __tablename__ = "events"

    event_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    date = Column(DateTime, nullable=False)
    venue = Column(String, nullable=False)
    organizer = Column(String, nullable=False)
    category = Column(String, nullable=False)
    rsvp_limit = Column(Integer, nullable=False)
    posted_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    rsvps = relationship("EventRSVP", back_populates="event", cascade="all, delete-orphan")
