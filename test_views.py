"""
Quick test to check if views exist in the database
"""
from sqlalchemy import create_engine, text, inspect

# MySQL Configuration
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'MySQL@2025',
    'database': 'ecommerce_db'
}

def get_engine():
    from urllib.parse import quote_plus
    user = MYSQL_CONFIG['user']
    pwd = quote_plus(MYSQL_CONFIG['password'])
    connection_string = (
        f"mysql+pymysql://{user}:{pwd}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
    )
    return create_engine(connection_string)

print("Checking for views in the database...\n")

engine = get_engine()
inspector = inspect(engine)

# Get all views
all_views = inspector.get_view_names()
print(f"Found {len(all_views)} views:")
for view in sorted(all_views):
    print(f"  - {view}")

print("\n" + "="*50)

# Test delivery_coordinator access
print("\nTesting delivery_coordinator access...")
from urllib.parse import quote_plus
pwd = quote_plus('DeliveryPass678!')
test_engine = create_engine(
    f"mysql+pymysql://delivery_coordinator:{pwd}"
    f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
)

try:
    with test_engine.connect() as conn:
        # Try to list all accessible objects
        result = conn.execute(text("SHOW TABLES"))
        tables = [row[0] for row in result]
        print(f"\ndelivery_coordinator can see {len(tables)} tables/views:")
        for table in sorted(tables):
            print(f"  - {table}")

        # Try to query ActiveDeliveryView
        print("\nTrying to query ActiveDeliveryView...")
        try:
            result = conn.execute(text("SELECT * FROM ActiveDeliveryView LIMIT 5"))
            rows = result.fetchall()
            print(f"✅ SUCCESS! Retrieved {len(rows)} rows from ActiveDeliveryView")
        except Exception as e:
            print(f"❌ ERROR querying ActiveDeliveryView: {e}")

except Exception as e:
    print(f"❌ ERROR connecting as delivery_coordinator: {e}")
