# Nexus Backend

Backend for the Nexus student application, built with FastAPI.

## Setup
1. `python -m venv venv`
2. `source venv/bin/activate` or `.\venv\Scripts\Activate.ps1`
3. `pip install -r requirements.txt`

## Environment Variables
Create a `.env` file using `.env.example` as a template:
- `DATABASE_URL`
- `SECRET_KEY`
- `CLOUDINARY_URL`
- `FCM_SERVER_KEY`
- `ALLOWED_ORIGINS`

## Running Tests
Run tests using:
`pytest app/tests/ -v`

## Team
- Backend Developer
- Frontend Developer
