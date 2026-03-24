import uuid
from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from app.database import Base

try:
    # Use native UUID for postgres if possible, fallback to String for SQLite
    import sqlalchemy.dialects.postgresql
except ImportError:
    pass

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    # added phone field to User model for contact seller functionality
    phone = Column(String, nullable=True)
