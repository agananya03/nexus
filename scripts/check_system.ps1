Write-Host "--- Nexus System Readiness Check ---" -ForegroundColor Cyan

# Check Python
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    $pyVersion = python --version
    Write-Host "[OK] Python installed: $pyVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Python not found. Please install Python 3.8+." -ForegroundColor Red
}

# Check Flutter
if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
    $fluVersion = (flutter --version | Select-Object -First 1)
    Write-Host "[OK] Flutter installed: $fluVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Flutter not found. Please install Flutter SDK." -ForegroundColor Red
}

# Check .env file
if (Test-Path ".env") {
    Write-Host "[OK] .env file found." -ForegroundColor Green
} else {
    Write-Host "[WARNING] .env file not found. Please create one based on requirements." -ForegroundColor Yellow
}

# Check requirements.txt
if (Test-Path "requirements.txt") {
    Write-Host "[OK] requirements.txt found." -ForegroundColor Green
} else {
    Write-Host "[ERROR] requirements.txt missing!" -ForegroundColor Red
}

Write-Host "------------------------------------"
Write-Host "Read README.md for more details." -ForegroundColor Cyan
