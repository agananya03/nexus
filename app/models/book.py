import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Float
from app.database import Base

class BookListing(Base):
    __tablename__ = "books"

    book_id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    author = Column(String, nullable=False)
    edition = Column(String, nullable=False)
    subject = Column(String, nullable=False)
    condition = Column(String, nullable=False) # Excellent/Good/Fair
    price = Column(Float, nullable=False)
    image_url = Column(String, nullable=True)
    seller_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    is_sold = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
