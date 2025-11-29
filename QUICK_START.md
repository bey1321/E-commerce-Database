# 🚀 Quick Start Guide

## Run the Dashboard (3 Easy Steps)

### Option 1: Using the Batch File (Easiest - Windows)
1. Double-click [run_dashboard.bat](run_dashboard.bat)
2. Wait for dependencies to install
3. Dashboard opens automatically in your browser!

### Option 2: Manual Commands
```bash
# Step 1: Install dependencies
pip install -r requirements.txt

# Step 2: Run the app
streamlit run app.py
```

## First Time Using the Dashboard?

### CRUD Operations Tutorial

1. **Click "CRUD Operations"** in the sidebar
2. **Select a table** (try "customer" first)
3. **Try each operation**:

   **Create a Customer:**
   - Click "Create"
   - Fill in the form
   - Click "Create Record"

   **View All Customers:**
   - Click "Read"
   - Scroll through the table

   **Update a Customer:**
   - Click "Update"
   - Select a customer from dropdown
   - Edit the form
   - Click "Update Record"

   **Delete a Customer:**
   - Click "Delete"
   - Select a customer
   - Click "Confirm Delete"

### Visualizations Tutorial

1. **Click "Visualizations"** in the sidebar
2. **Try these charts** (in order):
   - Customer Age Distribution
   - Product Sales Analysis
   - Payment Status Breakdown
   - Geographical Distribution

## 💡 Pro Tips

- **Date Format**: Always use yyyy-mm-dd (e.g., 2024-03-15)
- **Use Date Picker**: Click the calendar icon instead of typing dates
- **Primary Keys**: They're auto-detected and protected from editing
- **Interactive Charts**: Hover, zoom, and click on visualizations
- **Safe Operations**: All queries use SQL injection prevention

## 🎯 What Tables Should I Start With?

### Easy Tables (Good for Learning)
- `customer` - Simple structure, all data types
- `product` - Good for practicing CRUD
- `category` - Small table, quick operations

### Complex Tables (Advanced)
- `orders` - Has foreign keys
- `payment` - Multiple relationships
- `delivery` - Connected to orders

### Junction Tables (Many-to-Many)
- `customerCard` - Composite primary key
- `orderProduct` - Links orders and products
- `productCategory` - Product categorization

## ⚠️ Important Notes

1. **Foreign Keys**: When creating records in tables with foreign keys (like `orders`), make sure the referenced records exist first (e.g., create customer before creating their order)

2. **Primary Keys**:
   - Auto-increment PKs are handled automatically
   - Manual PKs need to be unique
   - Composite PKs require all parts

3. **Dates**:
   - Format: yyyy-mm-dd
   - Example: 2024-03-15
   - Use the date picker for accuracy

4. **Backups**: Consider backing up [database.db](database.db) before major operations

## 🔧 Troubleshooting

**Problem**: Dashboard won't start
- **Solution**: Run `pip install -r requirements.txt` first

**Problem**: Date errors
- **Solution**: Use the date picker or format yyyy-mm-dd

**Problem**: Foreign key constraint error
- **Solution**: Create referenced records first (e.g., customer before order)

**Problem**: Can't see my changes
- **Solution**: The page auto-refreshes after operations

## 📊 Recommended Workflow

### Adding New Data
1. Start with independent tables (customer, product, supplier)
2. Then add relationship data (addresses, emails)
3. Finally add transactional data (orders, payments)

### Analyzing Data
1. Check raw data with Read operation
2. Use visualizations for insights
3. Cross-reference multiple charts

### Updating Records
1. Use Read to find the record
2. Note the index number
3. Use Update and select that index

## 🎨 Customization Ideas

Want to extend the dashboard? Try:
- Adding new visualizations based on your queries
- Creating custom filters in Read operations
- Building aggregate reports
- Exporting data to CSV (add pandas `.to_csv()`)

## ✅ Quick Test Checklist

Run through these to verify everything works:

- [ ] Open dashboard successfully
- [ ] View customer table (Read)
- [ ] Create a new test customer
- [ ] Update the test customer
- [ ] Delete the test customer
- [ ] View Customer Age Distribution chart
- [ ] View Product Sales Analysis chart
- [ ] Check Geographical Distribution

## 📚 Next Steps

Once comfortable with basics:
1. Explore all 40+ tables in your database
2. Try all 8 visualizations
3. Practice with complex tables
4. Experiment with the data

---

**Need Help?** Check the full [README.md](README.md) for detailed documentation.
