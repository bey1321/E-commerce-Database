# 🗄️ Database Management Dashboard

A complete Streamlit + SQLAlchemy dashboard for managing your SQLite database with full CRUD operations and advanced visualizations.

## 📋 Features

### CRUD Operations
- ✅ **Create**: Automatically generated forms for all tables with smart input types
- ✅ **Read**: Interactive data tables with all records
- ✅ **Update**: Pre-filled forms for editing existing records
- ✅ **Delete**: Safe deletion with confirmation

### Advanced Visualizations
1. **Customer Age Distribution** - Histogram showing age demographics
2. **Customer Growth Over Time** - Cumulative growth chart
3. **Product Sales Analysis** - Bar chart of product performance
4. **Order Amount Distribution** - Scatter plot of orders over time
5. **Payment Status Breakdown** - Pie chart of payment statuses
6. **Delivery Status Overview** - Bar chart of delivery statuses
7. **Discount Usage Analysis** - Analysis of discount types
8. **Geographical Distribution** - Country-based address distribution with map

## 🚀 Quick Start

### Prerequisites
- Python 3.8 or higher
- Your existing SQLite database file ([database.db](database.db))

### Installation

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the application**:
   ```bash
   streamlit run app.py
   ```

3. **Open in browser**:
   The application will automatically open in your default browser at `http://localhost:8501`

## 🎯 How to Use

### CRUD Operations

1. **Select "CRUD Operations"** from the sidebar
2. **Choose a table** from the dropdown
3. **Select an operation** (Create, Read, Update, Delete)
4. **Follow the on-screen forms**

#### Create
- Fill in the form fields
- Date fields use a date picker (format: yyyy-mm-dd)
- Numeric fields use number inputs
- Click "Create Record" to insert

#### Read
- View all records in an interactive table
- Scroll through data
- See total record count

#### Update
- Select a record by index
- Modify the pre-filled form
- Primary keys are shown but cannot be edited
- Click "Update Record" to save changes

#### Delete
- Select a record by index
- Review the record details
- Click "Confirm Delete" to remove

### Visualizations

1. **Select "Visualizations"** from the sidebar
2. **Choose a visualization** from the dropdown
3. **View interactive charts** with metrics

All visualizations are:
- Interactive (hover, zoom, pan)
- Built with Plotly for professional quality
- Derived from SQL queries on your actual data

## 🔒 Security Features

- **SQL Injection Prevention**: All queries use parameterized statements (`:placeholder` format)
- **Input Validation**: Date formats are validated before database operations
- **Error Handling**: User-friendly error messages for all operations
- **Type Safety**: Automatic type detection and validation

## 📊 Database Schema Support

This dashboard automatically adapts to your database schema:
- Auto-detects primary keys
- Identifies column types (text, numeric, date)
- Handles composite primary keys
- Supports all SQLite data types

## 🛠️ Technical Architecture

### Core Technologies
- **Streamlit**: Interactive web interface
- **SQLAlchemy**: Database ORM and connection management
- **Pandas**: Data manipulation and analysis
- **Plotly**: Interactive visualizations

### Key Components

#### Database Connection
```python
@st.cache_resource
def get_engine():
    return create_engine(f"sqlite:///{DATABASE_PATH}")
```
- Cached engine for performance
- Connection pooling via SQLAlchemy

#### Helper Functions
- `fetch_table_data(table_name)`: Retrieve all table data
- `execute_sql(query, params)`: Execute parameterized queries
- `get_table_columns(table_name)`: Get column metadata
- `get_primary_key(table_name)`: Auto-detect primary keys

#### Smart Form Generation
- Automatic input type selection based on column type
- Date picker for date columns
- Number input for numeric columns
- Text input for strings

## 📁 File Structure

```
new_database_project/
├── app.py                  # Main Streamlit application
├── database.db            # Your SQLite database
├── requirements.txt       # Python dependencies
├── README.md             # This file
├── normal_Schema.sql     # Database schema (reference)
└── normal_insert.sql     # Sample data (reference)
```

## 🎨 Customization

### Adding More Visualizations

Add new visualization functions following this pattern:

```python
def viz_your_custom_chart():
    st.subheader("Your Chart Title")
    try:
        engine = get_engine()
        query = text("YOUR SQL QUERY HERE")
        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='column1', y='column2')
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No data available")
    except Exception as e:
        st.error(f"Error: {str(e)}")
```

Then add it to the visualization selector in `main()`.

### Changing Database Path

Edit the `DATABASE_PATH` variable at the top of [app.py](app.py):

```python
DATABASE_PATH = "your_database.db"
```

## 🐛 Troubleshooting

### Common Issues

**Q: "No tables found in database"**
- Ensure [database.db](database.db) exists in the project directory
- Check file permissions

**Q: Date validation errors**
- Use format: yyyy-mm-dd (e.g., 2024-03-15)
- Use the date picker instead of typing

**Q: Foreign key constraint errors**
- Ensure referenced records exist before creating dependent records
- Check foreign key relationships in your schema

**Q: Performance issues with large tables**
- The Read operation loads all records - consider adding pagination for very large tables
- Visualizations are optimized with SQL aggregations

## 📈 Performance Tips

1. **Database Indexing**: Ensure your database has proper indexes
2. **Selective Reads**: Use SQL filtering in visualizations
3. **Caching**: SQLAlchemy engine is cached with `@st.cache_resource`
4. **Batch Operations**: For bulk inserts, consider using SQL scripts

## 🔄 Updates and Maintenance

### Updating Dependencies
```bash
pip install --upgrade -r requirements.txt
```

### Backing Up Database
```bash
# Create a backup before major operations
cp database.db database.backup.db
```

## 📝 Notes

- Primary keys with AUTOINCREMENT are automatically skipped in Create forms
- Composite primary keys are fully supported
- All dates should be in yyyy-mm-dd format
- The dashboard preserves your existing database structure
- No schema modifications are made to your database

## 🤝 Support

For issues or questions:
1. Check the error message in the dashboard
2. Review the console output where Streamlit is running
3. Verify your database schema matches expected structure

## 📜 License

This dashboard is provided as-is for database management purposes.

---

**Built with ❤️ using Streamlit + SQLAlchemy**
