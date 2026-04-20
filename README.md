# Nexus Project

Nexus is a full-stack application featuring a FastAPI backend and a Flutter frontend.

## 📂 Project Structure

This repository is a monorepo containing both the frontend and backend of the Nexus application:

- `frontend/`: Flutter frontend application (Features, Core, Shared).
- `backend/`: Python FastAPI backend application (Models, Routers, Schemas).
- `scripts/`: Useful scripts for system verification, testing, and deployment.

## 🚀 Getting Started

### Prerequisites

- **Python 3.8+**
- **Flutter SDK**
- **Git**

---

### 📥 First Time Setup

Before running the project for the first time, you must install the required dependencies:

**Backend**:
Navigate to the backend directory and install Python requirements.
```powershell
cd backend
pip install -r requirements.txt
```

**Frontend**:
Navigate to the frontend directory and fetch Flutter packages.
```powershell
cd frontend
flutter pub get
```

---

### 🛠️ Backend Setup (FastAPI)

1. **Navigate to the backend directory**:
   ```powershell
   cd backend
   ```

2. **Configure Environment**:
   Ensure `.env` exists in the `backend/` directory. You can use the default SQLite database by running the migration or using `create_db.py`.

3. **Run the server**:
   ```powershell
   python -m uvicorn app.main:app --reload
   ```
   The API will be available at `http://127.0.0.1:8000`.
   Docs: `http://127.0.0.1:8000/docs`

---

### 📱 Frontend Setup (Flutter)

1. **Navigate to the frontend directory**:
   ```powershell
   cd frontend
   ```

2. **Run the application**:
   ```powershell
   flutter run
   ```
   *Note: Ensure you have an emulator running or a physical device connected.*

---

### ✅ Checking if everything is working

#### 1. Quick System Check
Run the provided PowerShell script to verify your environment requirements:
```powershell
.\scripts\check_system.ps1
```

#### 2. Backend Verification
Visit `http://127.0.0.1:8000/` in your browser. You should see:
```json
{"message": "Nexus API is running"}
```

#### 3. Frontend Verification
The app should launch and redirect to the **Login Screen**. If you can see the login interface, the frontend is initialized correctly.
