from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from app.core.database import get_db
from app.models.user import User
from app.models.study_group import StudyGroup
from app.models.group_membership import GroupMembership
from app.models.message import Message
from app.schemas.group_schema import GroupCreate, GroupResponse, MessageResponse
from app.core.auth import get_current_user

router = APIRouter()

@router.post("/", response_model=GroupResponse)
def create_group(group: GroupCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    new_group = StudyGroup(
        name=group.name,
        subject=group.subject,
        description=group.description,
        max_members=group.max_members,
        created_by=current_user.user_id
    )
    db.add(new_group)
    db.flush() 

    membership = GroupMembership(
        group_id=new_group.group_id,
        user_id=current_user.user_id
    )
    db.add(membership)
    db.commit()
    db.refresh(new_group)
    
    return GroupResponse(
        group_id=new_group.group_id,
        name=new_group.name,
        subject=new_group.subject,
        description=new_group.description,
        max_members=new_group.max_members,
        member_count=1,
        created_by=new_group.created_by,
        created_at=new_group.created_at
    )

@router.get("/", response_model=List[GroupResponse])
def get_groups(subject: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(
        StudyGroup, 
        func.count(GroupMembership.id).label('member_count')
    ).outerjoin(GroupMembership, StudyGroup.group_id == GroupMembership.group_id).group_by(StudyGroup.group_id)
    
    if subject:
        query = query.filter(StudyGroup.subject == subject)
        
    results = query.all()
    
    group_responses = []
    for group, count in results:
        group_responses.append(GroupResponse(
            group_id=group.group_id,
            name=group.name,
            subject=group.subject,
            description=group.description,
            max_members=group.max_members,
            member_count=count,
            created_by=group.created_by,
            created_at=group.created_at
        ))
    return group_responses

@router.get("/{group_id}", response_model=GroupResponse)
def get_group(group_id: str, db: Session = Depends(get_db)):
    result = db.query(
        StudyGroup, 
        func.count(GroupMembership.id).label('member_count')
    ).outerjoin(GroupMembership, StudyGroup.group_id == GroupMembership.group_id)\
     .filter(StudyGroup.group_id == group_id)\
     .group_by(StudyGroup.group_id).first()
     
    if not result:
        raise HTTPException(status_code=404, detail="Group not found")
        
    group, count = result
    return GroupResponse(
        group_id=group.group_id,
        name=group.name,
        subject=group.subject,
        description=group.description,
        max_members=group.max_members,
        member_count=count,
        created_by=group.created_by,
        created_at=group.created_at
    )

@router.post("/{group_id}/join")
def join_group(group_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    group = db.query(StudyGroup).filter(StudyGroup.group_id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")
        
    member_count = db.query(GroupMembership).filter(GroupMembership.group_id == group_id).count()
    if member_count >= group.max_members:
        raise HTTPException(status_code=400, detail="Group is full")
        
    existing_membership = db.query(GroupMembership).filter(
        GroupMembership.group_id == group_id,
        GroupMembership.user_id == current_user.user_id
    ).first()
    if existing_membership:
        raise HTTPException(status_code=400, detail="Already a member")
        
    membership = GroupMembership(group_id=group_id, user_id=current_user.user_id)
    db.add(membership)
    db.commit()
    return {"detail": "Joined successfully"}

@router.post("/{group_id}/leave")
def leave_group(group_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    membership = db.query(GroupMembership).filter(
        GroupMembership.group_id == group_id,
        GroupMembership.user_id == current_user.user_id
    ).first()
    if not membership:
        raise HTTPException(status_code=400, detail="Not a member of this group")
        
    db.delete(membership)
    db.commit()
    return {"detail": "Left successfully"}

@router.get("/{group_id}/messages", response_model=List[MessageResponse])
def get_group_messages(group_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    membership = db.query(GroupMembership).filter(
        GroupMembership.group_id == group_id,
        GroupMembership.user_id == current_user.user_id
    ).first()
    if not membership:
        raise HTTPException(status_code=403, detail="Must be a member to view messages")
        
    query = db.query(Message, User.name.label('sender_name')).join(User, Message.sender_id == User.user_id)\
              .filter(Message.group_id == group_id)\
              .order_by(Message.sent_at.desc())\
              .limit(50)
              
    results = query.all()
    results.reverse()
    
    return [
        MessageResponse(
            msg_id=msg.msg_id,
            content=msg.content,
            sent_at=msg.sent_at,
            group_id=msg.group_id,
            sender_id=msg.sender_id,
            sender_name=name
        ) for msg, name in results
    ]
