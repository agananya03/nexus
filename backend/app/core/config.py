import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost:5432/nexus_db")
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
CLOUDINARY_URL = os.getenv("CLOUDINARY_URL", "")
FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY", "")
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
