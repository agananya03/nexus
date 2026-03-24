import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey
from app.database import Base

class InternshipListing(Base):
    __tablename__ = "internships"

    listing_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    company = Column(String, nullable=False)
    role = Column(String, nullable=False)
    location = Column(String, nullable=False)
    stipend = Column(String, nullable=False)
    domain = Column(String, nullable=False)
    deadline = Column(DateTime, nullable=False)
    apply_link = Column(String, nullable=False)
    posted_by = Column(String(36), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
