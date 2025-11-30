# MySQL Streamlit Dashboard Setup Instructions

## Prerequisites

1. ✅ **MySQL Server** must be installed and running
2. ✅ **Python 3.8+** must be installed
3. ✅ **Database created** - Your `ecommerce_db` database should exist in MySQL

## Step 1: Configure Database Connection

Open **`app.py`** and update the MySQL configuration (lines 20-25):

```python
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',           # ⚠️ CHANGE THIS to your MySQL username
    'password': '',           # ⚠️ CHANGE THIS to your MySQL password
    'database': 'ecommerce_db'
}
```

### Example Configuration:

```python
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'MySecurePassword123',
    'database': 'ecommerce_db'
}
```

## Step 2: Install Required Packages

### Option A: Automatic Installation (Recommended) ⭐

Simply double-click:
```
run_dashboard.bat
```

This will:
- ✅ Create a virtual environment
- ✅ Install all dependencies
- ✅ Launch the dashboard

### Option B: Manual Installation

```bash
# Create virtual environment (optional but recommended)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Step 3: Run the Dashboard

### Using Batch File (Windows) - Easiest Method
Double-click: **`run_dashboard.bat`**

### Manual Command
```bash
streamlit run app.py
```

## Step 4: Access the Dashboard

Once running, the dashboard will automatically open in your browser at:
```
http://localhost:8501
```

## Features

### 📋 CRUD Operations
- **Create**: Add new records to any table with auto-increment detection
- **Read**: View all records in a table with pagination
- **Update**: Modify existing records with constraint validation
- **Delete**: Remove records with confirmation dialog

### 📊 Visualizations
- 📈 **Customer Age Distribution** - Histogram of customer ages
- 📊 **Customer Growth Over Time** - Cumulative customer registration
- 👥 **Customer Account Status** - Active/Inactive/Suspended breakdown
- 🛒 **Product Sales Analysis** - Top selling products
- 📦 **Product Stock Status** - Inventory status distribution
- 💰 **Order Amount Distribution** - Order values over time
- 📋 **Order Status Overview** - Pending/Processing/Shipped/Delivered
- 💳 **Payment Status Breakdown** - Payment completion rates

## Troubleshooting

### ❌ Error: "Access denied for user"
**Solution:**
- Check your MySQL username and password in `app.py` (lines 20-25)
- Verify MySQL server is running
- Ensure user has access to `ecommerce_db`

**Test connection:**
```bash
mysql -u root -p
# Enter your password
USE ecommerce_db;
SHOW TABLES;
```

### ❌ Error: "Unknown database 'ecommerce_db'"
**Solution:**
Create the database first:
```sql
CREATE DATABASE ecommerce_db;
```

Then run your schema file:
```bash
mysql -u root -p ecommerce_db < normal_Schema_MySQL.sql
```

### ❌ Error: "ModuleNotFoundError: No module named 'pymysql'"
**Solution:**
Install requirements:
```bash
pip install -r requirements.txt
```

### ❌ Error: "Can't connect to MySQL server"
**Solution:**
Verify MySQL is running:
- **Windows**: Check Services (look for MySQL80 or similar)
  - Press `Win + R`, type `services.msc`, press Enter
  - Find MySQL service and ensure it's "Running"
- **Mac**: `brew services list`
- **Linux**: `sudo systemctl status mysql`

Check port 3306 is not blocked:
```bash
netstat -an | findstr 3306
```

### ❌ Error: "No tables found in database"
**Solution:**
1. Make sure you've run the schema creation script
2. Check database name is correct in `app.py`
3. Verify tables exist:
   ```sql
   USE ecommerce_db;
   SHOW TABLES;
   ```

### ❌ Dashboard loads but shows errors
**Solution:**
- Ensure sample data is inserted in tables
- Check MySQL user has SELECT, INSERT, UPDATE, DELETE privileges:
  ```sql
  GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'your_user'@'localhost';
  FLUSH PRIVILEGES;
  ```

## Security Notes

⚠️ **IMPORTANT**: Never commit your password to version control!

### For Development:
Currently using hardcoded credentials (acceptable for local development)

### For Production:
Use environment variables:

1. Install python-dotenv:
   ```bash
   pip install python-dotenv
   ```

2. Create `.env` file (add to `.gitignore`):
   ```
   MYSQL_HOST=localhost
   MYSQL_PORT=3306
   MYSQL_USER=root
   MYSQL_PASSWORD=YourSecurePassword
   MYSQL_DATABASE=ecommerce_db
   ```

3. Update `app.py`:
   ```python
   import os
   from dotenv import load_dotenv

   load_dotenv()

   MYSQL_CONFIG = {
       'host': os.getenv('MYSQL_HOST', 'localhost'),
       'port': int(os.getenv('MYSQL_PORT', 3306)),
       'user': os.getenv('MYSQL_USER', 'root'),
       'password': os.getenv('MYSQL_PASSWORD', ''),
       'database': os.getenv('MYSQL_DATABASE', 'ecommerce_db')
   }
   ```

## Database Schema

The dashboard supports all tables in your e-commerce database:

**Core Tables:**
- `customer` - Customer information and profiles
- `product` - Product catalog with SKU, pricing, stock
- `orders` - Order transactions and tracking
- `payment` - Payment processing and status
- `card` - Saved payment card details (masked)

**Inventory & Supply:**
- `category` - Product categorization
- `supplier` - Supplier information
- `supplierProduct` - Supplier-product relationships

**Customer Engagement:**
- `rating` - Product reviews and ratings
- `wishList` - Customer wishlists
- `cart` - Shopping cart management

**Promotions:**
- `discount` - Discount campaigns
- `promoCode` - Promotional codes
- `giftCard` - Gift card management

**Logistics:**
- `delivery` - Delivery tracking
- `deliveryPerson` - Delivery personnel
- `address` - Address information
- `country`, `state`, `city` - Geographical data

**Returns:**
- `returnTable` - Product return requests

## Quick Start Checklist

- [ ] MySQL Server installed and running
- [ ] Database `ecommerce_db` created
- [ ] Schema loaded (`normal_Schema_MySQL.sql`)
- [ ] Sample data inserted (`normal_insert.sql`)
- [ ] MySQL credentials updated in `app.py`
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Dashboard launched (`run_dashboard.bat` or `streamlit run app.py`)
- [ ] Browser opened to http://localhost:8501
- [ ] 🎉 Enjoy your database management system!

## Advanced Features

### Data Validation
- ✅ Automatic CHECK constraint detection
- ✅ Primary key protection (read-only)
- ✅ Foreign key relationship preservation
- ✅ Date format validation
- ✅ Numeric range validation

### Security Features
- ✅ SQL injection prevention (parameterized queries)
- ✅ Transaction-based operations
- ✅ User privilege enforcement
- ✅ Audit table exclusion from CRUD

### User Experience
- ✅ Auto-increment ID detection and display
- ✅ Dropdown menus for constrained values
- ✅ Date pickers for date fields
- ✅ Number inputs for numeric fields
- ✅ Responsive table display
- ✅ Interactive visualizations with Plotly

## Need Help?

1. Check error messages in the terminal window
2. Verify MySQL connection with `mysql` command line
3. Ensure all prerequisites are met
4. Review this documentation
5. Check that database schema matches expected structure

## Support

For issues or questions:
- 📧 Check error messages for specific guidance
- 📝 Review MySQL error logs
- 🔍 Verify connection settings
- ✅ Ensure database schema is properly created

---

**Happy Database Managing! 🚀**
