from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from app.database import get_db
from app.models.event import Event
from app.models.event_rsvp import EventRSVP
from app.models.user import User
from app.schemas.event import EventCreate, EventOut, RSVPOut, AttendeeOut

def get_current_user_id() -> str:
    return "demo-user-id"

router = APIRouter(prefix="/events", tags=["Events"])


@router.get("/", response_model=List[EventOut])
def list_events(
    category: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    now = datetime.utcnow()
    q = db.query(Event).filter(Event.date >= now)
    if category and category.lower() != "all":
        q = q.filter(Event.category.ilike(f"%{category}%"))
    events = q.order_by(Event.date).all()
    result = []
    for ev in events:
        ev_dict = ev.__dict__.copy()
        ev_dict["rsvp_count"] = len(ev.rsvps)
        result.append(EventOut(**ev_dict))
    return result


@router.post("/", response_model=EventOut, status_code=201)
def create_event(
    data: EventCreate,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    event = Event(**data.model_dump(), posted_by=current_user_id)
    db.add(event)
    db.commit()
    db.refresh(event)
    ev_dict = event.__dict__.copy()
    ev_dict["rsvp_count"] = 0
    return EventOut(**ev_dict)


@router.get("/{event_id}", response_model=EventOut)
def get_event(event_id: str, db: Session = Depends(get_db)):
    event = db.query(Event).filter(Event.event_id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    ev_dict = event.__dict__.copy()
    ev_dict["rsvp_count"] = len(event.rsvps)
    return EventOut(**ev_dict)


@router.post("/{event_id}/rsvp", status_code=200)
def toggle_rsvp(
    event_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    event = db.query(Event).filter(Event.event_id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    existing = db.query(EventRSVP).filter(
        EventRSVP.event_id == event_id,
        EventRSVP.user_id == current_user_id,
    ).first()

    if existing:
        db.delete(existing)
        db.commit()
        return {"status": "removed", "message": "RSVP removed"}
    else:
        current_count = (
            db.query(EventRSVP).filter(EventRSVP.event_id == event_id).count()
        )
        if event.rsvp_limit and current_count >= event.rsvp_limit:
            raise HTTPException(status_code=400, detail="RSVP limit reached")
        rsvp = EventRSVP(event_id=event_id, user_id=current_user_id)
        db.add(rsvp)
        db.commit()
        return {"status": "added", "message": "RSVP added"}


@router.get("/{event_id}/rsvps", response_model=List[AttendeeOut])
def get_event_rsvps(event_id: str, db: Session = Depends(get_db)):
    event = db.query(Event).filter(Event.event_id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    rsvps = db.query(EventRSVP).filter(EventRSVP.event_id == event_id).all()
    attendees = []
    for r in rsvps:
        user = db.query(User).filter(User.id == r.user_id).first()
        if user:
            attendees.append(
                AttendeeOut(user_id=user.id, name=user.name, email=user.email)
            )
    return attendees
