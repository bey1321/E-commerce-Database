"""Quick test to verify dashboard components work"""
import sys
import sqlite3

# Test 1: Check if database exists
try:
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = cursor.fetchall()
    print("[OK] Database connected successfully")
    print(f"[OK] Found {len(tables)} tables in the database")
    conn.close()
except Exception as e:
    print(f"[ERROR] Database connection failed: {e}")
    sys.exit(1)

# Test 2: Import required modules
try:
    import streamlit
    import pandas
    import plotly
    import sqlalchemy
    print("[OK] All required packages imported successfully")
except ImportError as e:
    print(f"[ERROR] Package import failed: {e}")
    sys.exit(1)

# Test 3: Test SQLAlchemy connection
try:
    from sqlalchemy import create_engine, text, inspect
    engine = create_engine("sqlite:///database.db")
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    print("[OK] SQLAlchemy connected successfully")
    print(f"[OK] Can access {len(tables)} tables via SQLAlchemy")
except Exception as e:
    print(f"[ERROR] SQLAlchemy connection failed: {e}")
    sys.exit(1)

# Test 4: Test a simple query
try:
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM customer"))
        count = result.fetchone()[0]
        print("[OK] Sample query executed successfully")
        print(f"[OK] Found {count} customers in the database")
except Exception as e:
    print(f"[ERROR] Query execution failed: {e}")
    sys.exit(1)

print("\n" + "="*50)
print("SUCCESS: ALL TESTS PASSED!")
print("Dashboard is ready to run!")
print("="*50)
print("\nTo start the dashboard, run:")
print("  streamlit run app.py")
print("\nOr double-click: run_dashboard.bat")
