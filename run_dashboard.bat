@echo off
echo ========================================
echo Database Management Dashboard
echo ========================================
echo.
echo Installing dependencies...
pip install -r requirements.txt
echo.
echo Starting Streamlit dashboard...
echo.
streamlit run app.py
