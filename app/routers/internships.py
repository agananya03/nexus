from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.internship import InternshipListing
from app.schemas.internship import InternshipCreate, InternshipOut

# Simple auth stub — replace with your real auth dependency
def get_current_user_id() -> str:
    # Return a fixed ID for demonstration; wire up your real JWT auth here
    return "demo-user-id"

router = APIRouter(prefix="/internships", tags=["Internships"])


@router.get("/", response_model=List[InternshipOut])
def list_internships(
    domain: Optional[str] = Query(None),
    location: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    q = db.query(InternshipListing)
    if domain:
        q = q.filter(InternshipListing.domain.ilike(f"%{domain}%"))
    if location:
        q = q.filter(InternshipListing.location.ilike(f"%{location}%"))
    return q.order_by(InternshipListing.created_at.desc()).all()


@router.post("/", response_model=InternshipOut, status_code=201)
def create_internship(
    data: InternshipCreate,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    listing = InternshipListing(**data.model_dump(), posted_by=current_user_id)
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return listing


@router.get("/{internship_id}", response_model=InternshipOut)
def get_internship(internship_id: str, db: Session = Depends(get_db)):
    listing = db.query(InternshipListing).filter(
        InternshipListing.listing_id == internship_id
    ).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Internship not found")
    return listing


@router.delete("/{internship_id}", status_code=204)
def delete_internship(
    internship_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    listing = db.query(InternshipListing).filter(
        InternshipListing.listing_id == internship_id
    ).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Internship not found")
    if listing.posted_by != current_user_id:
        raise HTTPException(status_code=403, detail="Not authorised")
    db.delete(listing)
    db.commit()
