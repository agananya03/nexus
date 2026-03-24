import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class EventRSVP(Base):
    __tablename__ = "event_rsvps"

    rsvp_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    event_id = Column(String(36), ForeignKey("events.event_id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    rsvped_at = Column(DateTime, default=datetime.utcnow)

    event = relationship("Event", back_populates="rsvps")
    # user = relationship("User")
