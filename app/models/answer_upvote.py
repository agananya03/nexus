import uuid
from sqlalchemy import Column, String, ForeignKey, UniqueConstraint
from app.database import Base

class AnswerUpvote(Base):
    __tablename__ = "answer_upvotes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    answer_id = Column(String(36), ForeignKey("answers.answer_id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)

    __table_args__ = (
        UniqueConstraint("answer_id", "user_id", name="uq_answer_user_upvote"),
    )
