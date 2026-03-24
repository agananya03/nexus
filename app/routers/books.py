import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
import cloudinary
import cloudinary.uploader
from app.database import get_db
from app.models.book import BookListing
from app.models.user import User
from app.schemas.book import BookOut, BookDetailOut

cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME", "your_cloud_name"),
    api_key=os.getenv("CLOUDINARY_API_KEY", "your_api_key"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET", "your_api_secret"),
)

def get_current_user_id() -> str:
    return "demo-user-id"

router = APIRouter(prefix="/books", tags=["Books"])


@router.get("/", response_model=List[BookOut])
def list_books(
    subject: Optional[str] = Query(None),
    condition: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    q = db.query(BookListing).filter(BookListing.is_sold == False)
    if subject:
        q = q.filter(BookListing.subject.ilike(f"%{subject}%"))
    if condition:
        q = q.filter(BookListing.condition.ilike(f"%{condition}%"))
    return q.order_by(BookListing.created_at.desc()).all()


@router.post("/", response_model=BookOut, status_code=201)
async def create_book(
    title: str = Form(...),
    author: str = Form(...),
    edition: str = Form(...),
    subject: str = Form(...),
    condition: str = Form(...),
    price: float = Form(...),
    image: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    image_url = None
    if image:
        contents = await image.read()
        upload_result = cloudinary.uploader.upload(
            contents,
            public_id=f"nexus/books/{uuid.uuid4()}",
            resource_type="image",
        )
        image_url = upload_result.get("secure_url")

    book = BookListing(
        title=title,
        author=author,
        edition=edition,
        subject=subject,
        condition=condition,
        price=price,
        image_url=image_url,
        seller_id=current_user_id,
    )
    db.add(book)
    db.commit()
    db.refresh(book)
    return book


@router.get("/{book_id}", response_model=BookDetailOut)
def get_book(book_id: str, db: Session = Depends(get_db)):
    book = db.query(BookListing).filter(BookListing.book_id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    seller = db.query(User).filter(User.id == book.seller_id).first()
    detail = BookDetailOut.model_validate(book)
    detail.seller_name = seller.name if seller else "Unknown"
    detail.seller_email = seller.email if seller else ""
    detail.seller_phone = seller.phone if seller else None
    return detail


@router.put("/{book_id}/sold", response_model=BookOut)
def mark_sold(
    book_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    book = db.query(BookListing).filter(BookListing.book_id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if book.seller_id != current_user_id:
        raise HTTPException(status_code=403, detail="Not authorised")
    book.is_sold = True
    db.commit()
    db.refresh(book)
    return book


@router.delete("/{book_id}", status_code=204)
def delete_book(
    book_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    book = db.query(BookListing).filter(BookListing.book_id == book_id).first()
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    if book.seller_id != current_user_id:
        raise HTTPException(status_code=403, detail="Not authorised")
    db.delete(book)
    db.commit()
