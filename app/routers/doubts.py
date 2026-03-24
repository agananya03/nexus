from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import List, Optional

from app.database import get_db
from app.models.doubt import Doubt
from app.models.answer import Answer
from app.models.answer_upvote import AnswerUpvote
from app.models.user import User
from app.schemas.doubt_schema import (
    DoubtCreate, DoubtResponse,
    AnswerCreate, AnswerResponse,
    ResolveRequest,
)

# Replace with your real JWT auth dependency
def get_current_user_id() -> str:
    return "demo-user-id"

router = APIRouter(tags=["Doubt Solver"])


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _build_doubt_response(doubt: Doubt, db: Session) -> DoubtResponse:
    answer_count = db.query(Answer).filter(Answer.doubt_id == doubt.doubt_id).count()
    tags = [t.strip() for t in doubt.tags.split(",")] if doubt.tags else []
    return DoubtResponse(
        doubt_id=doubt.doubt_id,
        question=doubt.question,
        subject=doubt.subject,
        semester=doubt.semester,
        tags=tags,
        asked_by=doubt.asked_by,
        is_resolved=doubt.is_resolved,
        answer_count=answer_count,
        created_at=doubt.created_at,
    )


def _build_answer_response(
    answer: Answer, db: Session, current_user_id: str
) -> AnswerResponse:
    upvotes = (
        db.query(AnswerUpvote)
        .filter(AnswerUpvote.answer_id == answer.answer_id)
        .count()
    )
    user_has_upvoted = (
        db.query(AnswerUpvote)
        .filter(
            AnswerUpvote.answer_id == answer.answer_id,
            AnswerUpvote.user_id == current_user_id,
        )
        .first()
        is not None
    )
    answerer = db.query(User).filter(User.id == answer.answered_by).first()
    return AnswerResponse(
        answer_id=answer.answer_id,
        content=answer.content,
        upvotes=upvotes,
        doubt_id=answer.doubt_id,
        answered_by=answer.answered_by,
        answered_by_name=answerer.name if answerer else "Unknown",
        is_accepted=answer.is_accepted,
        created_at=answer.created_at,
        user_has_upvoted=user_has_upvoted,
    )


# ─── Doubts ───────────────────────────────────────────────────────────────────

@router.post("/doubts/", response_model=DoubtResponse, status_code=201)
def create_doubt(
    data: DoubtCreate,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    doubt = Doubt(
        question=data.question,
        description=data.description,
        subject=data.subject,
        semester=data.semester,
        tags=",".join(data.tags),
        asked_by=current_user_id,
    )
    db.add(doubt)
    db.commit()
    db.refresh(doubt)
    return _build_doubt_response(doubt, db)


@router.get("/doubts/", response_model=List[DoubtResponse])
def list_doubts(
    subject: Optional[str] = Query(None),
    is_resolved: Optional[bool] = Query(None),
    db: Session = Depends(get_db),
):
    q = db.query(Doubt)
    if subject:
        q = q.filter(Doubt.subject.ilike(f"%{subject}%"))
    if is_resolved is not None:
        q = q.filter(Doubt.is_resolved == is_resolved)
    doubts = q.order_by(Doubt.created_at.desc()).all()
    return [_build_doubt_response(d, db) for d in doubts]


@router.get("/doubts/{doubt_id}", response_model=dict)
def get_doubt(
    doubt_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    doubt = db.query(Doubt).filter(Doubt.doubt_id == doubt_id).first()
    if not doubt:
        raise HTTPException(status_code=404, detail="Doubt not found")

    answers = (
        db.query(Answer)
        .filter(Answer.doubt_id == doubt_id)
        .all()
    )
    # Sort by upvote count descending
    built_answers = [_build_answer_response(a, db, current_user_id) for a in answers]
    built_answers.sort(key=lambda x: x.upvotes, reverse=True)

    doubt_resp = _build_doubt_response(doubt, db)
    return {
        **doubt_resp.model_dump(),
        "description": doubt.description,
        "answers": [a.model_dump() for a in built_answers],
    }


# ─── Answers ──────────────────────────────────────────────────────────────────

@router.post("/doubts/{doubt_id}/answers", response_model=AnswerResponse, status_code=201)
def post_answer(
    doubt_id: str,
    data: AnswerCreate,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    doubt = db.query(Doubt).filter(Doubt.doubt_id == doubt_id).first()
    if not doubt:
        raise HTTPException(status_code=404, detail="Doubt not found")

    answer = Answer(
        content=data.content,
        doubt_id=doubt_id,
        answered_by=current_user_id,
    )
    db.add(answer)
    db.commit()
    db.refresh(answer)
    return _build_answer_response(answer, db, current_user_id)


# ─── Upvote ───────────────────────────────────────────────────────────────────

@router.post("/answers/{answer_id}/upvote")
def toggle_upvote(
    answer_id: str,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    answer = db.query(Answer).filter(Answer.answer_id == answer_id).first()
    if not answer:
        raise HTTPException(status_code=404, detail="Answer not found")

    existing = (
        db.query(AnswerUpvote)
        .filter(
            AnswerUpvote.answer_id == answer_id,
            AnswerUpvote.user_id == current_user_id,
        )
        .first()
    )

    if existing:
        db.delete(existing)
        db.commit()
        action = "removed"
    else:
        upvote = AnswerUpvote(answer_id=answer_id, user_id=current_user_id)
        db.add(upvote)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=409, detail="Already upvoted")
        action = "added"

    count = db.query(AnswerUpvote).filter(AnswerUpvote.answer_id == answer_id).count()
    return {"status": action, "upvotes": count}


# ─── Resolve ──────────────────────────────────────────────────────────────────

@router.put("/doubts/{doubt_id}/resolve")
def resolve_doubt(
    doubt_id: str,
    body: ResolveRequest,
    db: Session = Depends(get_db),
    current_user_id: str = Depends(get_current_user_id),
):
    doubt = db.query(Doubt).filter(Doubt.doubt_id == doubt_id).first()
    if not doubt:
        raise HTTPException(status_code=404, detail="Doubt not found")
    if doubt.asked_by != current_user_id:
        raise HTTPException(status_code=403, detail="Only the asker can resolve this doubt")

    doubt.is_resolved = True

    if body.accepted_answer_id:
        answer = (
            db.query(Answer)
            .filter(
                Answer.answer_id == body.accepted_answer_id,
                Answer.doubt_id == doubt_id,
            )
            .first()
        )
        if answer:
            # Clear previous accepted flags
            db.query(Answer).filter(Answer.doubt_id == doubt_id).update(
                {"is_accepted": False}
            )
            answer.is_accepted = True

    db.commit()
    return {"status": "resolved", "doubt_id": doubt_id}
