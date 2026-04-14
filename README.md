# Nexus Project

Nexus is a full-stack application featuring a FastAPI backend and a Flutter frontend.

## 🚀 Getting Started

### Prerequisites

- **Python 3.8+**
- **Flutter SDK**
- **Git**

---

### 📥 First Time Setup

Before running the project for the first time, install the required dependencies:

**Backend**:
```powershell
pip install -r requirements.txt
```

**Frontend**:
```powershell
flutter pub get
```

---

### 🛠️ Backend Setup (FastAPI)

1. **Navigate to the root directory**:
   ```powershell
   cd c:\Users\ASUS\OneDrive\Desktop\nexus_itw
   ```

2. **Install dependencies**:
   ```powershell
   pip install -r requirements.txt
   ```

3. **Configure Environment**:
   Ensure `.env` exists in the root directory. You can use the default SQLite database configured in `app/database.py`.

4. **Run the server**:
   ```powershell
   python -m uvicorn app.main:app --reload
   ```
   The API will be available at `http://127.0.0.1:8000`.
   Docs: `http://127.0.0.1:8000/docs`

---

### 📱 Frontend Setup (Flutter)

1. **Install dependencies**:
   ```powershell
   flutter pub get
   ```

2. **Run the application**:
   ```powershell
   flutter run
   ```
   *Note: Ensure you have an emulator running or a physical device connected.*

---

### ✅ Checking if everything is working

#### 1. Quick System Check
Run the provided PowerShell script to verify your environment:
```powershell
.\check_system.ps1
```

#### 2. Backend Verification
Visit `http://127.0.0.1:8000/` in your browser. You should see:
```json
{"message": "Nexus API is running"}
```

#### 3. Frontend Verification
The app should launch and redirect to the **Login Screen**. If you can see the login interface, the frontend is initialized correctly.

#### 4. Integration Tests
Run the (placeholder) integration test:
```powershell
flutter test integration_test/app_test.dart
```

## 📂 Project Structure

- `app/`: FastAPI backend (Models, Routers, Schemas).
- `lib/`: Flutter frontend (Features, Core, Shared).
- `integration_test/`: E2E tests.
- `nexus.db`: SQLite database (auto-created).
