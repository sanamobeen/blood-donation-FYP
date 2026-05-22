@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM 🚀 Django Server Startup Script for Mobile Development
REM ═══════════════════════════════════════════════════════════════════════════════
REM This script starts the Django server on all interfaces (0.0.0.0)
REM which allows Android emulators and physical devices to connect.

echo 🔧 Starting Django Blood Donation Backend Server...
echo.

REM Kill any existing Django processes on port 8001
echo Cleaning up existing processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8001" ^| findstr "LISTENING"') do (
    echo Killing process %%a
    taskkill /F /PID %%a >nul 2>&1
)

timeout /t 2 >nul

REM Start Django server on all interfaces
echo Starting server on http://0.0.0.0:8001
echo.
echo ✅ Server will accept connections from:
echo    - Android Emulator: http://10.0.2.2:8001
echo    - Physical Device: http://YOUR_LOCAL_IP:8001
echo    - Desktop/Web: http://localhost:8001
echo.
echo Press Ctrl+C to stop the server
echo.

cd /d "%~dp0"
python manage.py runserver 0.0.0.0:8001

pause