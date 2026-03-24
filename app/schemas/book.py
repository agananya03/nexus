from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class BookCreate(BaseModel):
    title: str
    author: str
    edition: str
    subject: str
    condition: str  # Excellent / Good / Fair
    price: float

class BookOut(BaseModel):
    book_id: str
    title: str
    author: str
    edition: str
    subject: str
    condition: str
    price: float
    image_url: Optional[str] = None
    seller_id: str
    is_sold: bool
    created_at: datetime

    class Config:
        from_attributes = True

class BookDetailOut(BookOut):
    seller_name: str
    seller_email: str
    seller_phone: Optional[str] = None
