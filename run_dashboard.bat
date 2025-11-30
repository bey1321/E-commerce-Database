@echo off
echo ========================================
echo E-Commerce MySQL Dashboard Launcher
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
echo.

REM Install/Update dependencies
echo Installing required packages...
pip install -r requirements.txt
echo.

REM Run the Streamlit app
echo ========================================
echo Starting MySQL Dashboard...
echo ========================================
echo.
echo IMPORTANT: Make sure to update MySQL credentials in app.py:
echo   - Lines 20-25: Set your MySQL username and password
echo.
echo The dashboard will open in your browser automatically.
echo Press Ctrl+C to stop the dashboard
echo ========================================
echo.

streamlit run app.py

pause
