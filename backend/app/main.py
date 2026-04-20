import uvicorn
import os
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from typing import Dict, List
import json

from app.core.database import engine, Base, SessionLocal
from app.models.user import User
from app.models.note import Note
from app.models.study_group import StudyGroup
from app.models.group_membership import GroupMembership
from app.models.message import Message
from app.routers import auth, notes, groups, mock_data
from app.core.auth import verify_token
from app.core import config

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.ALLOWED_ORIGINS if config.ALLOWED_ORIGINS != ["*"] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    os.system("alembic upgrade head")

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(notes.router, prefix="/notes", tags=["notes"])
app.include_router(groups.router, prefix="/groups", tags=["groups"])
app.include_router(mock_data.router)

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, group_id: str):
        await websocket.accept()
        if group_id not in self.active_connections:
            self.active_connections[group_id] = []
        self.active_connections[group_id].append(websocket)

    def disconnect(self, websocket: WebSocket, group_id: str):
        if group_id in self.active_connections:
            self.active_connections[group_id].remove(websocket)
            if not self.active_connections[group_id]:
                del self.active_connections[group_id]

    async def broadcast(self, group_id: str, message: dict):
        if group_id in self.active_connections:
            text_data = json.dumps(message)
            for connection in self.active_connections[group_id]:
                await connection.send_text(text_data)

manager = ConnectionManager()

@app.websocket("/ws/groups/{group_id}")
async def websocket_endpoint(websocket: WebSocket, group_id: str, token: str):
    try:
        payload = verify_token(token)
        user_id = payload.get("user_id")
        if not user_id:
            await websocket.close(code=1008)
            return
            
        db = SessionLocal()
        membership = db.query(GroupMembership).filter(
            GroupMembership.group_id == group_id,
            GroupMembership.user_id == user_id
        ).first()
        
        if not membership:
            db.close()
            await websocket.close(code=1008)
            return
            
    except Exception:
        await websocket.close(code=1008)
        return

    await manager.connect(websocket, group_id)
    try:
        while True:
            data = await websocket.receive_text()
            data_dict = json.loads(data)
            
            content = data_dict.get("content")
            sender_id = data_dict.get("sender_id") or user_id
            sender_name = data_dict.get("sender_name", "User")
            
            if content:
                new_msg = Message(
                    content=content,
                    group_id=group_id,
                    sender_id=sender_id
                )
                db.add(new_msg)
                db.commit()
                db.refresh(new_msg)
                
                broadcast_msg = {
                    "msg_id": str(new_msg.msg_id),
                    "content": new_msg.content,
                    "sender_id": str(new_msg.sender_id),
                    "sender_name": sender_name,
                    "group_id": str(new_msg.group_id),
                    "sent_at": new_msg.sent_at.isoformat()
                }
                
                await manager.broadcast(group_id, broadcast_msg)
    except WebSocketDisconnect:
        manager.disconnect(websocket, group_id)
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"status": "Nexus API running"}

if __name__ == "__main__":
    uvicorn.run("app.main:app", port=8000, reload=True)
