from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from typing import Optional, List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.note import Note
from app.models.user import User
from app.schemas.note_schema import NoteResponse
from app.core.auth import get_current_user
from app.utils.cloudinary import configure_cloudinary, upload_file

router = APIRouter()
configure_cloudinary()

@router.post("/", response_model=NoteResponse)
def create_note(
    title: str = Form(...),
    subject: str = Form(...),
    semester: int = Form(...),
    branch: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if not file.content_type.startswith("image/") and file.content_type != "application/pdf":
        raise HTTPException(status_code=400, detail="Only PDF or image files are allowed")
        
    try:
        file_bytes = file.file.read()
        secure_url = upload_file(file_bytes, file.filename, "nexus/notes")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upload file to Cloudinary: {str(e)}")
        
    new_note = Note(
        title=title,
        subject=subject,
        semester=semester,
        branch=branch,
        file_url=secure_url,
        uploader_id=current_user.user_id
    )
    db.add(new_note)
    db.commit()
    db.refresh(new_note)
    return new_note

@router.get("/", response_model=List[NoteResponse])
def get_notes(
    subject: Optional[str] = None,
    semester: Optional[int] = None,
    branch: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Note)
    if subject:
        query = query.filter(Note.subject == subject)
    if semester:
        query = query.filter(Note.semester == semester)
    if branch:
        query = query.filter(Note.branch == branch)
        
    return query.order_by(Note.created_at.desc()).all()

@router.get("/{note_id}", response_model=NoteResponse)
def get_note(note_id: str, db: Session = Depends(get_db)):
    note = db.query(Note).filter(Note.note_id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note

@router.delete("/{note_id}")
def delete_note(note_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = db.query(Note).filter(Note.note_id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
        
    if str(note.uploader_id) != str(current_user.user_id):
        raise HTTPException(status_code=403, detail="Not authorized to delete this note")
        
    db.delete(note)
    db.commit()
    return {"detail": "Note deleted successfully"}
