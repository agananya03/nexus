from fastapi import FastAPI
from app.database import Base, engine
from app.models import user, internship, event, event_rsvp, book, doubt, answer, answer_upvote
from app.routers import internships, events, books, doubts

# Create all tables on startup (use Alembic for production migrations)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Nexus API", version="1.0.0")

app.include_router(internships.router)
app.include_router(events.router)
app.include_router(books.router)
app.include_router(doubts.router)


@app.get("/")
def root():
    return {"message": "Nexus API is running"}
