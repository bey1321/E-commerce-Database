"""
Streamlit + SQLAlchemy Dashboard for MySQL
Complete CRUD Operations and Advanced Visualizations
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, date
from sqlalchemy import create_engine, text, inspect
import re

# =====================================================
# DATABASE CONNECTION & HELPER FUNCTIONS
# =====================================================

# MySQL Configuration
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'MySQL@2025',
    'database': 'ecommerce_db'
}

@st.cache_resource
def get_engine():
    """Create and cache SQLAlchemy engine for MySQL"""
    from urllib.parse import quote_plus
    password = quote_plus(MYSQL_CONFIG['password'])
    connection_string = (
        f"mysql+pymysql://{MYSQL_CONFIG['user']}:{password}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
    )
    return create_engine(connection_string)

def fetch_table_data(table_name):
    """Fetch all data from a specific table"""
    try:
        engine = get_engine()
        query = text(f"SELECT * FROM {table_name}")
        with engine.connect() as conn:
            df = pd.read_sql(query, conn)
        return df
    except Exception as e:
        st.error(f"Error fetching data from {table_name}: {str(e)}")
        return pd.DataFrame()

def execute_sql(query, params=None):
    """Execute SQL query with parameters to prevent SQL injection"""
    try:
        engine = get_engine()
        with engine.begin() as conn:  # Use begin() for auto-commit transaction
            if params:
                result = conn.execute(text(query), params)
            else:
                result = conn.execute(text(query))
            return True, "Operation successful"
    except Exception as e:
        return False, str(e)

def get_table_columns(table_name):
    """Get column names and types for a table"""
    try:
        engine = get_engine()
        inspector = inspect(engine)
        columns = inspector.get_columns(table_name)
        return columns
    except Exception as e:
        st.error(f"Error getting columns for {table_name}: {str(e)}")
        return []

def get_primary_key(table_name):
    """Get primary key column(s) for a table"""
    try:
        engine = get_engine()
        inspector = inspect(engine)
        pk = inspector.get_pk_constraint(table_name)
        if pk and pk['constrained_columns']:
            return pk['constrained_columns']
        # Fallback: assume first column if no PK defined
        columns = inspector.get_columns(table_name)
        if columns:
            return [columns[0]['name']]
        return []
    except Exception as e:
        st.error(f"Error getting primary key for {table_name}: {str(e)}")
        return []

def get_all_tables():
    """Get list of all tables in the database"""
    try:
        engine = get_engine()
        inspector = inspect(engine)
        # Filter out audit tables and views
        all_tables = inspector.get_table_names()
        # Exclude audit tables and system tables
        excluded = ['customer_audit', 'card_audit', 'product_audit', 'orders_audit', 'payment_audit', 'security_log']
        tables = [t for t in all_tables if t not in excluded and not t.endswith('_audit')]
        return sorted(tables)
    except Exception as e:
        st.error(f"Error getting table names: {str(e)}")
        return []

def validate_date(date_string):
    """Validate date format (yyyy-mm-dd)"""
    try:
        datetime.strptime(str(date_string), '%Y-%m-%d')
        return True
    except ValueError:
        return False

def is_date_column(column_name):
    """Check if column name suggests it's a date field"""
    date_keywords = ['date', 'dob', 'time', 'timestamp']
    return any(keyword in column_name.lower() for keyword in date_keywords)

def is_numeric_column(column_type):
    """Check if column type is numeric"""
    numeric_types = ['INT', 'TINYINT', 'SMALLINT', 'MEDIUMINT', 'BIGINT', 'DECIMAL', 'FLOAT', 'DOUBLE']
    return any(num_type in str(column_type).upper() for num_type in numeric_types)

def get_next_id(table_name, id_column):
    """Get the next auto-increment ID value"""
    try:
        engine = get_engine()
        query = text(f"SELECT MAX({id_column}) as max_id FROM {table_name}")
        with engine.connect() as conn:
            result = conn.execute(query)
            row = result.fetchone()
            if row and row[0] is not None:
                return row[0] + 1
            return 1
    except Exception:
        return 1

def get_check_constraint_values(table_name, column_name):
    """Extract allowed values from CHECK constraint for MySQL"""
    try:
        engine = get_engine()
        # Query to get CHECK constraints from information_schema
        query = text("""
            SELECT CHECK_CLAUSE
            FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
            WHERE CONSTRAINT_SCHEMA = :db_name
            AND TABLE_NAME = :table_name
        """)

        with engine.connect() as conn:
            result = conn.execute(query, {'db_name': MYSQL_CONFIG['database'], 'table_name': table_name})

            for row in result:
                clause = row[0]
                # Look for pattern like: Gender IN ('Male', 'Female')
                if column_name.lower() in clause.lower():
                    # Extract values within parentheses after IN
                    match = re.search(rf"{column_name}\s+IN\s*\(([^)]+)\)", clause, re.IGNORECASE)
                    if match:
                        values_str = match.group(1)
                        # Extract quoted values
                        values = re.findall(r"'([^']+)'", values_str)
                        return values

        return None
    except Exception as e:
        return None

# =====================================================
# CRUD OPERATIONS
# =====================================================

def create_record(table_name):
    """Create a new record in the selected table"""
    st.subheader(f"➕ Add New Record to {table_name}")

    columns = get_table_columns(table_name)
    pk_columns = get_primary_key(table_name)

    with st.form(f"create_form_{table_name}"):
        form_data = {}

        for col in columns:
            col_name = col['name']
            col_type = col['type']

            # Skip auto-increment IDs (primary key with INTEGER type)
            is_auto_id = (col_name in pk_columns and
                         'INT' in str(col_type).upper() and
                         len(pk_columns) == 1 and
                         col.get('autoincrement', False))

            if is_auto_id:
                next_id = get_next_id(table_name, col_name)
                st.info(f"🔢 {col_name} (Auto-generated): **{next_id}**")
                continue

            # Check for domain constraints (CHECK IN constraint)
            allowed_values = get_check_constraint_values(table_name, col_name)

            # Determine input type based on column
            if allowed_values:
                # Use selectbox for fields with CHECK IN constraints
                form_data[col_name] = st.selectbox(
                    f"{col_name}",
                    options=[''] + allowed_values,
                    key=f"create_{col_name}"
                )
            elif is_date_column(col_name):
                value = st.date_input(f"{col_name}", value=None, key=f"create_{col_name}")
                if value:
                    form_data[col_name] = value.strftime('%Y-%m-%d')
            elif is_numeric_column(col_type):
                if 'DECIMAL' in str(col_type).upper() or 'FLOAT' in str(col_type).upper() or 'DOUBLE' in str(col_type).upper():
                    form_data[col_name] = st.number_input(f"{col_name}", value=0.0, step=0.01, key=f"create_{col_name}")
                else:
                    form_data[col_name] = st.number_input(f"{col_name}", value=0, step=1, key=f"create_{col_name}")
            else:
                form_data[col_name] = st.text_input(f"{col_name}", key=f"create_{col_name}")

        submitted = st.form_submit_button("Create Record")

        if submitted:
            # Validate dates
            date_error = False
            for col_name, value in form_data.items():
                if is_date_column(col_name) and value and not validate_date(value):
                    st.error(f"Invalid date format for {col_name}. Use yyyy-mm-dd")
                    date_error = True

            if not date_error:
                # Build INSERT query with placeholders
                columns_str = ", ".join(form_data.keys())
                placeholders = ", ".join([f":{key}" for key in form_data.keys()])
                query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"

                success, message = execute_sql(query, form_data)

                if success:
                    st.success(f"✅ Record created successfully in {table_name}!")
                    st.rerun()
                else:
                    st.error(f"❌ Error creating record: {message}")

def read_records(table_name):
    """Display all records from the selected table"""
    st.subheader(f"📊 View All Records from {table_name}")

    df = fetch_table_data(table_name)

    if not df.empty:
        st.dataframe(df, use_container_width=True, height=400)
        st.info(f"Total records: {len(df)}")
    else:
        st.warning(f"No records found in {table_name}")

def update_record(table_name):
    """Update an existing record"""
    st.subheader(f"✏️ Update Record in {table_name}")

    df = fetch_table_data(table_name)

    if df.empty:
        st.warning(f"No records available to update in {table_name}")
        return

    pk_columns = get_primary_key(table_name)

    # Let user select a record to update
    st.write("Select a record to update:")
    selected_index = st.selectbox(
        "Choose record by index",
        options=range(len(df)),
        format_func=lambda x: f"Row {x}: {dict(df.iloc[x])}",
        key=f"update_select_{table_name}"
    )

    if selected_index is not None:
        selected_row = df.iloc[selected_index]
        columns = get_table_columns(table_name)

        with st.form(f"update_form_{table_name}", clear_on_submit=False):
            form_data = {}
            pk_values = {}

            for col in columns:
                col_name = col['name']
                col_type = col['type']
                current_value = selected_row[col_name]

                # Store primary key values separately and show as read-only
                if col_name in pk_columns:
                    pk_values[col_name] = current_value
                    st.info(f"🔑 {col_name} (Primary Key - Cannot be modified): **{current_value}**")
                    continue

                # Check for domain constraints
                allowed_values = get_check_constraint_values(table_name, col_name)

                # Create input fields with current values
                if allowed_values:
                    # Use selectbox for fields with CHECK IN constraints
                    current_val = str(current_value) if pd.notna(current_value) else ''
                    if current_val not in allowed_values:
                        options = [''] + allowed_values
                    else:
                        options = allowed_values

                    default_index = options.index(current_val) if current_val in options else 0
                    form_data[col_name] = st.selectbox(
                        f"{col_name}",
                        options=options,
                        index=default_index,
                        key=f"update_{col_name}_{selected_index}"
                    )
                elif is_date_column(col_name):
                    if pd.notna(current_value) and current_value:
                        try:
                            if isinstance(current_value, str):
                                date_val = datetime.strptime(str(current_value), '%Y-%m-%d').date()
                            else:
                                date_val = current_value
                        except:
                            date_val = None
                    else:
                        date_val = None

                    value = st.date_input(f"{col_name}", value=date_val, key=f"update_{col_name}_{selected_index}")
                    if value:
                        form_data[col_name] = value.strftime('%Y-%m-%d')
                elif is_numeric_column(col_type):
                    if 'DECIMAL' in str(col_type).upper() or 'FLOAT' in str(col_type).upper() or 'DOUBLE' in str(col_type).upper():
                        form_data[col_name] = st.number_input(
                            f"{col_name}",
                            value=float(current_value) if pd.notna(current_value) else 0.0,
                            step=0.01,
                            key=f"update_{col_name}_{selected_index}"
                        )
                    else:
                        form_data[col_name] = st.number_input(
                            f"{col_name}",
                            value=int(current_value) if pd.notna(current_value) else 0,
                            step=1,
                            key=f"update_{col_name}_{selected_index}"
                        )
                else:
                    form_data[col_name] = st.text_input(
                        f"{col_name}",
                        value=str(current_value) if pd.notna(current_value) else "",
                        key=f"update_{col_name}_{selected_index}"
                    )

            submitted = st.form_submit_button("Update Record", type="primary")

            if submitted:
                # Validate dates
                date_error = False
                for col_name, value in form_data.items():
                    if is_date_column(col_name) and value and not validate_date(value):
                        st.error(f"Invalid date format for {col_name}. Use yyyy-mm-dd")
                        date_error = True

                if not date_error:
                    # Build UPDATE query with placeholders
                    set_clause = ", ".join([f"{key}=:{key}" for key in form_data.keys()])
                    where_clause = " AND ".join([f"{key}=:pk_{key}" for key in pk_values.keys()])
                    query = f"UPDATE {table_name} SET {set_clause} WHERE {where_clause}"

                    # Combine form data and pk values
                    params = {**form_data, **{f"pk_{k}": v for k, v in pk_values.items()}}

                    success, message = execute_sql(query, params)

                    if success:
                        st.success(f"✅ Record updated successfully in {table_name}!")
                        st.balloons()
                        st.rerun()
                    else:
                        st.error(f"❌ Error updating record: {message}")

def delete_record(table_name):
    """Delete a record from the table"""
    st.subheader(f"🗑️ Delete Record from {table_name}")

    df = fetch_table_data(table_name)

    if df.empty:
        st.warning(f"No records available to delete in {table_name}")
        return

    pk_columns = get_primary_key(table_name)

    # Display all records in a table first
    st.write("### All Records:")
    st.dataframe(df, use_container_width=True, height=300)

    st.write("---")

    # Let user select a record to delete by primary key
    st.write("### Select a record to delete:")

    # Create a more user-friendly display for selection
    if len(pk_columns) == 1:
        # Single primary key - show as simple dropdown
        pk_col = pk_columns[0]
        pk_values_list = df[pk_col].tolist()

        selected_pk = st.selectbox(
            f"Choose by {pk_col}",
            options=pk_values_list,
            format_func=lambda x: f"{pk_col}: {x}",
            key=f"delete_select_{table_name}"
        )

        selected_row = df[df[pk_col] == selected_pk].iloc[0]
    else:
        # Composite primary key - use index-based selection
        selected_index = st.selectbox(
            "Choose record by row number",
            options=range(len(df)),
            format_func=lambda x: f"Row {x}: {dict(df.iloc[x])}",
            key=f"delete_select_{table_name}"
        )
        selected_row = df.iloc[selected_index]

    if selected_row is not None:
        st.warning("⚠️ **You are about to delete this record:**")

        # Display selected record in a more readable format
        col1, col2 = st.columns([1, 3])
        with col2:
            for col_name in df.columns:
                st.text(f"{col_name}: {selected_row[col_name]}")

        st.write("---")

        # Use a form to properly handle the delete button
        with st.form(f"delete_form_{table_name}", clear_on_submit=False):
            st.warning("⚠️ This action cannot be undone!")
            submitted = st.form_submit_button("🗑️ Confirm Delete", type="primary")

            if submitted:
                # Build DELETE query with placeholders
                pk_values = {col: selected_row[col] for col in pk_columns}
                where_clause = " AND ".join([f"{key}=:{key}" for key in pk_values.keys()])
                query = f"DELETE FROM {table_name} WHERE {where_clause}"

                success, message = execute_sql(query, pk_values)

                if success:
                    st.success(f"✅ Record deleted successfully from {table_name}!")
                    st.rerun()
                else:
                    st.error(f"❌ Error deleting record: {message}")

# =====================================================
# VISUALIZATIONS
# =====================================================

def viz_customer_age_distribution():
    """Age Distribution of Customers"""
    st.subheader("📊 Customer Age Distribution")

    try:
        engine = get_engine()
        query = text("SELECT DOB FROM customer WHERE DOB IS NOT NULL")

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            # Calculate ages
            df['Age'] = df['DOB'].apply(lambda x: (datetime.now() - pd.to_datetime(x)).days // 365)

            fig = px.histogram(df, x='Age', nbins=20, title='Customer Age Distribution',
                             labels={'Age': 'Age (years)', 'count': 'Number of Customers'})
            fig.update_traces(marker_color='lightblue', marker_line_color='darkblue', marker_line_width=1.5)
            st.plotly_chart(fig, use_container_width=True)

            st.metric("Average Age", f"{df['Age'].mean():.1f} years")
        else:
            st.info("No customer data available")
    except Exception as e:
        st.error(f"Error generating age distribution: {str(e)}")

def viz_customer_growth():
    """Customer Growth Over Time"""
    st.subheader("📈 Customer Growth Over Time")

    try:
        engine = get_engine()
        query = text("""
            SELECT DATE(RegistrationDate) as RegDate, COUNT(*) as CustomerCount
            FROM customer
            WHERE RegistrationDate IS NOT NULL
            GROUP BY DATE(RegistrationDate)
            ORDER BY DATE(RegistrationDate)
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            df['RegDate'] = pd.to_datetime(df['RegDate'])
            df['CumulativeCustomers'] = df['CustomerCount'].cumsum()

            fig = px.line(df, x='RegDate', y='CumulativeCustomers',
                         title='Cumulative Customer Growth',
                         labels={'RegDate': 'Date', 'CumulativeCustomers': 'Total Customers'})
            fig.update_traces(line_color='green', line_width=3)
            st.plotly_chart(fig, use_container_width=True)

            st.metric("Total Customers", int(df['CumulativeCustomers'].iloc[-1]))
        else:
            st.info("No customer registration data available")
    except Exception as e:
        st.error(f"Error generating customer growth chart: {str(e)}")

def viz_product_sales():
    """Product Sales Distribution"""
    st.subheader("🛒 Product Sales Analysis")

    try:
        engine = get_engine()
        query = text("""
            SELECT p.ProductName,
                   COALESCE(SUM(op.Quantity), 0) as TotalSold
            FROM product p
            LEFT JOIN orderProduct op ON p.ProductID = op.ProductID
            GROUP BY p.ProductID, p.ProductName
            ORDER BY TotalSold DESC
            LIMIT 20
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='ProductName', y='TotalSold',
                        title='Top 20 Products by Sales',
                        labels={'ProductName': 'Product', 'TotalSold': 'Total Units Sold'},
                        color='TotalSold',
                        color_continuous_scale='Blues')
            st.plotly_chart(fig, use_container_width=True)

            col1, col2 = st.columns(2)
            col1.metric("Total Products", len(df))
            col2.metric("Total Units Sold", int(df['TotalSold'].sum()))
        else:
            st.info("No product sales data available")
    except Exception as e:
        st.error(f"Error generating product sales chart: {str(e)}")

def viz_order_distribution():
    """Order Amount Distribution"""
    st.subheader("💰 Order Amount Distribution")

    try:
        engine = get_engine()
        query = text("""
            SELECT OrderDate, TotalAmount, ShippingFee
            FROM orders
            ORDER BY OrderDate
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            df['OrderDate'] = pd.to_datetime(df['OrderDate'])

            fig = px.scatter(df, x='OrderDate', y='TotalAmount',
                           size='ShippingFee', title='Order Amount Over Time',
                           labels={'OrderDate': 'Date', 'TotalAmount': 'Order Amount ($)'})
            st.plotly_chart(fig, use_container_width=True)

            col1, col2, col3 = st.columns(3)
            col1.metric("Total Orders", len(df))
            col2.metric("Avg Order Value", f"${df['TotalAmount'].mean():.2f}")
            col3.metric("Total Revenue", f"${df['TotalAmount'].sum():.2f}")
        else:
            st.info("No order data available")
    except Exception as e:
        st.error(f"Error generating order distribution: {str(e)}")

def viz_payment_status():
    """Payment Status Breakdown"""
    st.subheader("💳 Payment Status Breakdown")

    try:
        engine = get_engine()
        query = text("""
            SELECT PaymentStatus, COUNT(*) as Count, SUM(Amount) as TotalAmount
            FROM payment
            GROUP BY PaymentStatus
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.pie(df, values='Count', names='PaymentStatus',
                        title='Payment Status Distribution',
                        color_discrete_sequence=px.colors.sequential.RdBu)
            st.plotly_chart(fig, use_container_width=True)

            st.dataframe(df, use_container_width=True)
        else:
            st.info("No payment data available")
    except Exception as e:
        st.error(f"Error generating payment status chart: {str(e)}")

def viz_order_status():
    """Order Status Overview"""
    st.subheader("📦 Order Status Overview")

    try:
        engine = get_engine()
        query = text("""
            SELECT OrderStatus, COUNT(*) as Count
            FROM orders
            GROUP BY OrderStatus
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='OrderStatus', y='Count',
                        title='Order Status Distribution',
                        labels={'OrderStatus': 'Status', 'Count': 'Number of Orders'},
                        color='Count',
                        color_continuous_scale='Viridis')
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No order data available")
    except Exception as e:
        st.error(f"Error generating order status chart: {str(e)}")

def viz_stock_status():
    """Stock Status Overview"""
    st.subheader("📦 Stock Status Overview")

    try:
        engine = get_engine()
        query = text("""
            SELECT StockStatus, COUNT(*) as Count
            FROM product
            GROUP BY StockStatus
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.pie(df, values='Count', names='StockStatus',
                        title='Product Stock Status Distribution')
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No product stock data available")
    except Exception as e:
        st.error(f"Error generating stock status chart: {str(e)}")

def viz_customer_by_status():
    """Customer Account Status"""
    st.subheader("👥 Customer Account Status")

    try:
        engine = get_engine()
        query = text("""
            SELECT AccountStatus, COUNT(*) as Count
            FROM customer
            GROUP BY AccountStatus
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='AccountStatus', y='Count',
                        title='Customer Account Status Distribution',
                        color='AccountStatus',
                        color_discrete_sequence=px.colors.qualitative.Set2)
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No customer data available")
    except Exception as e:
        st.error(f"Error generating customer status chart: {str(e)}")

# =====================================================
# MAIN APPLICATION
# =====================================================

def main():
    st.set_page_config(
        page_title="E-Commerce Database Dashboard",
        page_icon="🛒",
        layout="wide",
        initial_sidebar_state="expanded"
    )

    st.title("🛒 E-Commerce Database Management Dashboard")
    st.markdown("---")

    # Sidebar
    with st.sidebar:
        st.header("⚙️ Navigation")

        # Database connection info
        st.info(f"📊 Connected to: **{MYSQL_CONFIG['database']}**")

        # Get all tables
        tables = get_all_tables()

        if not tables:
            st.error("No tables found in database! Check your connection.")
            st.stop()

        # Mode selection
        mode = st.radio(
            "Select Mode",
            ["CRUD Operations", "Visualizations"],
            key="mode_select"
        )

        if mode == "CRUD Operations":
            st.markdown("### 📋 CRUD Operations")
            selected_table = st.selectbox("Select Table", tables, key="crud_table")

            crud_operation = st.radio(
                "Select Operation",
                ["Create", "Read", "Update", "Delete"],
                key="crud_op"
            )
        else:
            st.markdown("### 📊 Visualizations")
            viz_option = st.selectbox(
                "Select Visualization",
                [
                    "Customer Age Distribution",
                    "Customer Growth Over Time",
                    "Customer Account Status",
                    "Product Sales Analysis",
                    "Product Stock Status",
                    "Order Amount Distribution",
                    "Order Status Overview",
                    "Payment Status Breakdown"
                ],
                key="viz_select"
            )

    # Main content area
    if mode == "CRUD Operations":
        st.header(f"📋 {crud_operation} Operations - {selected_table}")

        if crud_operation == "Create":
            create_record(selected_table)
        elif crud_operation == "Read":
            read_records(selected_table)
        elif crud_operation == "Update":
            update_record(selected_table)
        elif crud_operation == "Delete":
            delete_record(selected_table)

    else:  # Visualizations
        if viz_option == "Customer Age Distribution":
            viz_customer_age_distribution()
        elif viz_option == "Customer Growth Over Time":
            viz_customer_growth()
        elif viz_option == "Customer Account Status":
            viz_customer_by_status()
        elif viz_option == "Product Sales Analysis":
            viz_product_sales()
        elif viz_option == "Product Stock Status":
            viz_stock_status()
        elif viz_option == "Order Amount Distribution":
            viz_order_distribution()
        elif viz_option == "Order Status Overview":
            viz_order_status()
        elif viz_option == "Payment Status Breakdown":
            viz_payment_status()

    # Footer
    st.markdown("---")
    st.markdown("*Dashboard built with Streamlit + SQLAlchemy + MySQL | Secure CRUD with parameterized queries*")

if __name__ == "__main__":
    main()
