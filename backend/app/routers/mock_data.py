from fastapi import APIRouter
import uuid
from datetime import datetime, timedelta

router = APIRouter()

# Mock Internships
mock_internships = [
    {
        "listing_id": str(uuid.uuid4()),
        "company": "Google",
        "role": "Software Engineering Intern",
        "domain": "Software",
        "stipend": "1,00,000",
        "deadline": (datetime.now() + timedelta(days=10)).isoformat(),
        "description": "Work on Google Cloud infrastructure. Must know Python, Go, and Kubernetes.",
        "application_link": "https://careers.google.com"
    },
    {
        "listing_id": str(uuid.uuid4()),
        "company": "Microsoft",
        "role": "Data Science Intern",
        "domain": "Data Science",
        "stipend": "80,000",
        "deadline": (datetime.now() + timedelta(days=5)).isoformat(),
        "description": "Analyze big data pipelines using Azure Data Explorer. Experience with PySpark preferred.",
        "application_link": "https://careers.microsoft.com"
    },
    {
        "listing_id": str(uuid.uuid4()),
        "company": "Figma",
        "role": "Product Design Intern",
        "domain": "Design",
        "stipend": "60,000",
        "deadline": (datetime.now() + timedelta(days=20)).isoformat(),
        "description": "Help design the next generation of collaborative tools. Portfolios mandatory.",
        "application_link": "https://figma.com/careers"
    }
]

@router.get("/internships/")
def get_internships(domain: str = None, location: str = None):
    results = mock_internships
    if domain:
        results = [i for i in results if i["domain"].lower() == domain.lower()]
    return results

@router.get("/internships/{id}")
def get_internship_by_id(id: str):
    return next((i for i in mock_internships if i["listing_id"] == id), mock_internships[0])


# Mock Events
mock_events = [
    {
        "event_id": str(uuid.uuid4()),
        "title": "Nexus Hackathon 2026",
        "category": "Hackathon",
        "date": (datetime.now() + timedelta(days=14)).isoformat(),
        "venue": "Main Auditorium",
        "rsvp_count": 120,
        "description": "A 48-hour hackathon to build solutions for college networking.",
        "organizer": "Tech Club"
    },
    {
        "event_id": str(uuid.uuid4()),
        "title": "Annual Sports Fest",
        "category": "Sports",
        "date": (datetime.now() + timedelta(days=3)).isoformat(),
        "venue": "College Ground",
        "rsvp_count": 450,
        "description": "Inter-department sports tournament. Football, Basketball, and more.",
        "organizer": "Sports Council"
    },
    {
        "event_id": str(uuid.uuid4()),
        "title": "AI & ML Workshop",
        "category": "Workshop",
        "date": (datetime.now() + timedelta(days=7)).isoformat(),
        "venue": "Lab 3, CS Block",
        "rsvp_count": 65,
        "description": "Hands on workshop on PyTorch and building LLM applications.",
        "organizer": "AI Club"
    }
]

@router.get("/events/")
def get_events(category: str = None):
    results = mock_events
    if category:
        results = [e for e in results if e["category"].lower() == category.lower()]
    return results

@router.get("/events/{id}")
def get_event_by_id(id: str):
    return next((e for e in mock_events if e["event_id"] == id), mock_events[0])

@router.post("/events/{id}/rsvp")
def rsvp_event(id: str):
    return {"status": "success", "message": "RSVP successful"}


# Mock Books
mock_books = [
    {
        "book_id": str(uuid.uuid4()),
        "title": "Introduction to Algorithms",
        "author": "Cormen, Leiserson, Rivest, Stein",
        "subject": "Computer Science",
        "condition": "Good",
        "price": "600",
        "seller_name": "Rahul M.",
        "description": "The standard CLRS book. Great condition, a few pencil highlights.",
        "image_url": None
    },
    {
        "book_id": str(uuid.uuid4()),
        "title": "Engineering Mathematics Vol 2",
        "author": "B.S. Grewal",
        "subject": "Mathematics",
        "condition": "Like New",
        "price": "400",
        "seller_name": "Sneha",
        "description": "Brand new, bought by mistake.",
        "image_url": None
    }
]

@router.get("/books/")
def get_books(subject: str = None, condition: str = None):
    return mock_books

@router.get("/books/{id}")
def get_book_by_id(id: str):
    return next((b for b in mock_books if b["book_id"] == id), mock_books[0])

@router.post("/books/")
def create_book():
    return mock_books[0]

@router.put("/books/{id}/sold")
def mark_book_sold(id: str):
    return {"status": "success"}


# Mock Doubts
mock_doubts = [
    {
        "doubt_id": str(uuid.uuid4()),
        "question": "How to implement QuickSort in C++ optimally?",
        "description": "I constantly get Time Limit Exceeded when partitioning. Can someone share an optimal pivot strategy?",
        "subject": "Data Structures",
        "semester": 3,
        "tags": ["C++", "Sorting", "DSA"],
        "is_resolved": False,
        "author_name": "Parvathy",
        "created_at": datetime.now().isoformat()
    },
    {
        "doubt_id": str(uuid.uuid4()),
        "question": "What is the physical significance of Maxwell's Equations?",
        "description": "I understood the math but struggling to grasp the physical intuition of displacement current.",
        "subject": "Physics",
        "semester": 2,
        "tags": ["Physics", "Electromagnetism"],
        "is_resolved": True,
        "author_name": "Aditya",
        "created_at": (datetime.now() - timedelta(days=2)).isoformat()
    }
]

@router.get("/doubts/")
def get_doubts(subject: str = None, is_resolved: bool = None):
    return mock_doubts

@router.get("/doubts/{id}")
def get_doubt_by_id(id: str):
    return next((d for d in mock_doubts if d["doubt_id"] == id), mock_doubts[0])

@router.post("/doubts/")
def post_doubt(data: dict):
    return {"status": "success", "doubt_id": str(uuid.uuid4())}

@router.post("/doubts/{id}/answers")
def post_answer(id: str, data: dict):
    return {"status": "success", "answer_id": str(uuid.uuid4())}
