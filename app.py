"""
Streamlit + SQLAlchemy Dashboard for MySQL
Complete CRUD Operations and Advanced Visualizations with Role-Based Access Control
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, date
from sqlalchemy import create_engine, text, inspect
import re

# =====================================================
# ROLE-BASED ACCESS CONTROL CONFIGURATION
# =====================================================

# Define role permissions - must match MySQL GRANT statements exactly
ROLE_PERMISSIONS = {
    'admin_user': {
        'name': 'Administrator',
        'tables': 'all',  # Access to all tables
        'operations': {'all': ['create', 'read', 'update', 'delete']},
        'visualizations': 'all'
    },
    'sales_manager': {
        'name': 'Sales Manager',
        'tables': ['customer', 'orders', 'product', 'orderProduct', 'payment', 'ordersummaryview'],
        'operations': {
            'customer': ['read'],  # GRANT SELECT
            'orders': ['read', 'update'],  # GRANT SELECT, UPDATE
            'product': ['read'],  # GRANT SELECT
            'orderProduct': ['read'],  # GRANT SELECT
            'payment': ['read'],  # GRANT SELECT
            'ordersummaryview': ['read']  # GRANT SELECT
        },
        'visualizations': ['customer_age', 'customer_growth', 'product_sales', 'order_amount', 'payment_status', 'order_status']
    },
    'customer_service': {
        'name': 'Customer Service',
        'tables': ['customer', 'orders', 'product', 'returnTable', 'payment', 'customerserviceview', 'returnmanagementview'],
        'operations': {
            'customer': ['read'],  # GRANT SELECT
            'orders': ['read'],  # GRANT SELECT
            'product': ['read'],  # GRANT SELECT
            'returnTable': ['read'],  # GRANT SELECT
            'payment': ['read'],  # GRANT SELECT
            'customerserviceview': ['read'],  # GRANT SELECT
            'returnmanagementview': ['read', 'update']  # GRANT SELECT, UPDATE
        },
        'visualizations': ['customer_age', 'customer_account_status', 'order_status']
    },
    'warehouse_staff': {
        'name': 'Warehouse Staff',
        'tables': ['product', 'supplierProduct', 'supplier', 'productAnalytics'],
        'operations': {
            'product': ['read', 'update'],  # GRANT SELECT, UPDATE
            'supplierProduct': ['read', 'create', 'update'],  # GRANT SELECT, INSERT, UPDATE
            'supplier': ['read'],  # GRANT SELECT
            'productAnalytics': ['read']  # GRANT SELECT
        },
        'visualizations': ['product_stock', 'product_sales']
    },
    'marketing_team': {
        'name': 'Marketing Team',
        'tables': ['marketinganalyticsview', 'product', 'productAnalytics', 'customer', 'orders', 'discount'],
        'operations': {
            'marketinganalyticsview': ['read'],  # GRANT SELECT
            'product': ['read'],  # GRANT SELECT
            'productAnalytics': ['read'],  # GRANT SELECT
            'customer': ['read'],  # GRANT SELECT
            'orders': ['read'],  # GRANT SELECT
            'discount': ['read']  # GRANT SELECT
        },
        'visualizations': 'all'  # Full analytics access
    },
    'delivery_coordinator': {
        'name': 'Delivery Coordinator',
        'tables': ['delivery', 'deliveryPerson', 'orders', 'customer', 'address', 'customerAddress', 'activedeliveryview'],
        'operations': {
            'delivery': ['read', 'update'],  # GRANT SELECT, UPDATE
            'deliveryPerson': ['read'],  # GRANT SELECT
            'orders': ['read'],  # GRANT SELECT
            'customer': ['read'],  # GRANT SELECT
            'address': ['read'],  # GRANT SELECT only - NO UPDATE!
            'customerAddress': ['read'],  # GRANT SELECT
            'activedeliveryview': ['read']  # GRANT SELECT
        },
        'visualizations': ['order_status']
    }
}

# =====================================================
# DATABASE CONNECTION & HELPER FUNCTIONS
# =====================================================

# MySQL Configuration for admin (used only for login verification)
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'MySQL@2025',
    'database': 'ecommerce_db'
}

def get_engine(username=None, password=None):
    """Create SQLAlchemy engine - uses role-based credentials if provided"""
    from urllib.parse import quote_plus

    if username and password:
        # Use role-based credentials
        user = username
        pwd = quote_plus(password)
    else:
        # Use default admin credentials from session or config
        if 'username' in st.session_state and 'password' in st.session_state:
            user = st.session_state.username
            pwd = quote_plus(st.session_state.password)
        else:
            user = MYSQL_CONFIG['user']
            pwd = quote_plus(MYSQL_CONFIG['password'])

    connection_string = (
        f"mysql+pymysql://{user}:{pwd}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{MYSQL_CONFIG['database']}"
    )
    return create_engine(connection_string)

# =====================================================
# AUTHENTICATION & AUTHORIZATION FUNCTIONS
# =====================================================

def authenticate_user(username, password):
    """Verify user credentials by attempting to connect to MySQL"""
    try:
        engine = get_engine(username, password)
        with engine.connect() as conn:
            # Test connection
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False

def get_user_role(username):
    """Get role name from username"""
    if username in ROLE_PERMISSIONS:
        return username
    return None

def get_role_name(role):
    """Get display name for role"""
    if role in ROLE_PERMISSIONS:
        return ROLE_PERMISSIONS[role]['name']
    return "Unknown"

def can_access_table(role, table_name):
    """Check if role has access to a specific table"""
    if role not in ROLE_PERMISSIONS:
        return False

    allowed_tables = ROLE_PERMISSIONS[role]['tables']
    if allowed_tables == 'all':
        return True
    return table_name in allowed_tables

def can_perform_operation(role, operation, table_name=None):
    """Check if role can perform specific operation on a table (create/read/update/delete)"""
    if role not in ROLE_PERMISSIONS:
        return False

    allowed_operations = ROLE_PERMISSIONS[role]['operations']

    # Admin has all operations on all tables
    if allowed_operations == {'all': ['create', 'read', 'update', 'delete']}:
        return True

    # If operations is a dict (table-specific permissions)
    if isinstance(allowed_operations, dict):
        if table_name and table_name in allowed_operations:
            return operation in allowed_operations[table_name]
        # Default: no permission if table not specified or not in dict
        return False

    # Legacy: if operations is a list (global permissions for all accessible tables)
    return operation in allowed_operations

def can_view_visualization(role, viz_key):
    """Check if role can view specific visualization"""
    if role not in ROLE_PERMISSIONS:
        return False

    allowed_viz = ROLE_PERMISSIONS[role]['visualizations']
    if allowed_viz == 'all':
        return True
    return viz_key in allowed_viz

def get_accessible_tables(role):
    """Get list of tables accessible to role"""
    if role not in ROLE_PERMISSIONS:
        return []

    allowed_tables = ROLE_PERMISSIONS[role]['tables']
    if allowed_tables == 'all':
        # Admin gets access to all tables including audit and security logs
        return get_all_tables(include_audit=True)

    # Get all tables and filter by permissions
    all_tables = get_all_tables(include_audit=False)
    return [t for t in all_tables if t in allowed_tables]

def logout():
    """Clear session and logout user"""
    for key in list(st.session_state.keys()):
        del st.session_state[key]
    st.rerun()

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

def get_all_tables(include_audit=False):
    """Get list of all tables and views in the database

    Args:
        include_audit: If True, includes audit tables and security logs (for admin only)
    """
    try:
        engine = get_engine()
        inspector = inspect(engine)
        # Get both tables and views
        all_tables = inspector.get_table_names()
        all_views = inspector.get_view_names()
        # Combine tables and views
        all_objects = all_tables + all_views

        if include_audit:
            # Admin: Include everything
            return sorted(all_objects)
        else:
            # Other roles: Exclude audit tables and security logs
            excluded = ['customer_audit', 'card_audit', 'product_audit', 'orders_audit', 'payment_audit', 'security_log']
            tables = [t for t in all_objects if t not in excluded and not t.endswith('_audit')]
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
# LOGIN PAGE
# =====================================================

def show_login_page():
    """Display login page"""
    st.set_page_config(
        page_title="Login - E-Commerce Dashboard",
        page_icon="🔐",
        layout="centered"
    )

    # Center the login form
    _, col2, _ = st.columns([1, 2, 1])

    with col2:
        st.title("🔐 E-Commerce Dashboard Login")
        st.markdown("---")

        # Login form
        with st.form("login_form"):
            st.subheader("Please enter your credentials")

            username = st.text_input("Username", placeholder="e.g., admin_user, sales_manager")
            password = st.text_input("Password", type="password")

            submitted = st.form_submit_button("🔓 Login", use_container_width=True)

            if submitted:
                if not username or not password:
                    st.error("⚠️ Please enter both username and password")
                elif authenticate_user(username, password):
                    role = get_user_role(username)
                    if role:
                        # Store credentials in session
                        st.session_state.logged_in = True
                        st.session_state.username = username
                        st.session_state.password = password
                        st.session_state.role = role
                        st.success(f"✅ Welcome, {get_role_name(role)}!")
                        st.rerun()
                    else:
                        st.error("❌ User role not recognized")
                else:
                    st.error("❌ Invalid username or password")

        st.markdown("---")

        # Display available roles (for demo purposes)
        with st.expander("ℹ️ Available User Roles"):
            st.markdown("""
            **Administrator:**
            - Username: `admin_user`
            - Password: `SecurePass123!`

            **Sales Manager:**
            - Username: `sales_manager`
            - Password: `SalesPass456!`

            **Customer Service:**
            - Username: `customer_service`
            - Password: `CSPass789!`

            **Warehouse Staff:**
            - Username: `warehouse_staff`
            - Password: `WarehousePass012!`

            **Marketing Team:**
            - Username: `marketing_team`
            - Password: `MarketPass345!`

            **Delivery Coordinator:**
            - Username: `delivery_coordinator`
            - Password: `DeliveryPass678!`
            """)

# =====================================================
# MAIN APPLICATION
# =====================================================

def main():
    # Check if user is logged in
    if 'logged_in' not in st.session_state or not st.session_state.logged_in:
        show_login_page()
        return

    # User is logged in - show dashboard
    st.set_page_config(
        page_title="E-Commerce Database Dashboard",
        page_icon="🛒",
        layout="wide",
        initial_sidebar_state="expanded"
    )

    role = st.session_state.role
    role_name = get_role_name(role)

    st.title(f"🛒 E-Commerce Database Management Dashboard")
    st.caption(f"👤 Logged in as: **{role_name}** ({st.session_state.username})")
    st.markdown("---")

    # Sidebar
    with st.sidebar:
        st.header("⚙️ Navigation")

        # User info and logout
        st.info(f"👤 **{role_name}**\n\n📊 Database: **{MYSQL_CONFIG['database']}**")

        if st.button("🚪 Logout", use_container_width=True):
            logout()

        st.markdown("---")

        # Get accessible tables for this role
        tables = get_accessible_tables(role)

        if not tables:
            st.error("No tables accessible with your permissions.")
            st.stop()

        # Mode selection
        mode = st.radio(
            "Select Mode",
            ["CRUD Operations", "View Data", "Visualizations"],
            key="mode_select"
        )

        if mode == "CRUD Operations":
            st.markdown("### 📋 CRUD Operations")

            # For admin, provide quick access to audit and security tables
            if role == 'admin_user':
                audit_tables = ['customer_audit', 'card_audit', 'product_audit', 'orders_audit', 'payment_audit', 'security_log']
                available_audit = [t for t in audit_tables if t in tables]

                if available_audit:
                    with st.expander("🔒 Quick Access: Audit & Security Tables", expanded=True):
                        st.markdown("**Audit Trail Tables:**")
                        for audit_table in available_audit:
                            if audit_table != 'security_log':
                                if st.button(f"📋 {audit_table}", key=f"quick_{audit_table}", use_container_width=True):
                                    st.session_state.selected_audit_table = audit_table
                                    st.session_state.auto_read_mode = True
                                    st.rerun()

                        if 'security_log' in available_audit:
                            st.markdown("**Security Log:**")
                            if st.button("🔐 security_log", key="quick_security_log", use_container_width=True):
                                st.session_state.selected_audit_table = 'security_log'
                                st.session_state.auto_read_mode = True
                                st.rerun()

            # Table selection
            default_table = st.session_state.get('selected_audit_table', None)
            if default_table and default_table in tables:
                default_index = tables.index(default_table)
                # Clear after using so it doesn't persist
                if 'selected_audit_table' in st.session_state:
                    del st.session_state.selected_audit_table
            else:
                default_index = 0

            selected_table = st.selectbox("Select Table", tables, index=default_index, key="crud_table")

            # Filter operations based on role permissions FOR THIS SPECIFIC TABLE
            available_operations = []
            if can_perform_operation(role, 'create', selected_table):
                available_operations.append("Create")
            if can_perform_operation(role, 'read', selected_table):
                available_operations.append("Read")
            if can_perform_operation(role, 'update', selected_table):
                available_operations.append("Update")
            if can_perform_operation(role, 'delete', selected_table):
                available_operations.append("Delete")

            if not available_operations:
                st.warning(f"⚠️ No operations available for table '{selected_table}' with your role")
                crud_operation = None
            else:
                # Auto-select "Read" if coming from quick access button
                auto_read = st.session_state.get('auto_read_mode', False)
                if auto_read and "Read" in available_operations:
                    default_op_index = available_operations.index("Read")
                    # Clear the flag after using
                    if 'auto_read_mode' in st.session_state:
                        del st.session_state.auto_read_mode
                else:
                    default_op_index = 0

                crud_operation = st.radio(
                    "Select Operation",
                    available_operations,
                    index=default_op_index,
                    key="crud_op"
                )
        elif mode == "View Data":
            st.markdown("### 👁️ Database Views")

            # Filter only views (tables ending with 'View' or starting with 'vw_')
            view_tables = [t for t in tables if 'View' in t or t.startswith('vw_')]

            if not view_tables:
                st.warning("No views available for your role")
                selected_view = None
            else:
                selected_view = st.selectbox("Select View", view_tables, key="view_select")
        else:
            st.markdown("### 📊 Visualizations")

            # Filter visualizations based on role permissions
            all_viz = {
                "Customer Age Distribution": "customer_age",
                "Customer Growth Over Time": "customer_growth",
                "Customer Account Status": "customer_account_status",
                "Product Sales Analysis": "product_sales",
                "Product Stock Status": "product_stock",
                "Order Amount Distribution": "order_amount",
                "Order Status Overview": "order_status",
                "Payment Status Breakdown": "payment_status"
            }

            available_viz = {k: v for k, v in all_viz.items() if can_view_visualization(role, v)}

            if not available_viz:
                st.warning("No visualizations available for your role")
                viz_option = None
            else:
                viz_option = st.selectbox(
                    "Select Visualization",
                    list(available_viz.keys()),
                    key="viz_select"
                )

    # Main content area
    if mode == "View Data" and selected_view:
        st.header(f"👁️ Database View: {selected_view}")

        # Add description for each view (only granted views)
        view_descriptions = {
            'ordersummaryview': 'Summary of all orders with customer and payment information',
            'customerserviceview': 'Customer service overview with order and return data',
            'returnmanagementview': 'Return management data for customer service',
            'marketinganalyticsview': 'Marketing analytics and customer insights',
            'activedeliveryview': 'Currently active deliveries and their status'
        }

        if selected_view in view_descriptions:
            st.info(f"📝 **Description:** {view_descriptions[selected_view]}")

        # Fetch and display view data
        try:
            df = fetch_table_data(selected_view)

            if not df.empty:
                # Add search functionality
                st.subheader("🔍 Search and Filter")
                search_col = st.selectbox("Search by column", ["All"] + list(df.columns))
                search_term = st.text_input("Search term", "")

                # Filter data based on search
                if search_term:
                    if search_col == "All":
                        # Search across all columns
                        mask = df.astype(str).apply(lambda x: x.str.contains(search_term, case=False, na=False)).any(axis=1)
                        filtered_df = df[mask]
                    else:
                        # Search in specific column
                        mask = df[search_col].astype(str).str.contains(search_term, case=False, na=False)
                        filtered_df = df[mask]

                    st.dataframe(filtered_df, use_container_width=True, height=500)
                    st.info(f"Showing {len(filtered_df)} of {len(df)} records")
                else:
                    st.dataframe(df, use_container_width=True, height=500)
                    st.info(f"Total records: {len(df)}")

                # Add export option
                st.download_button(
                    label="📥 Download as CSV",
                    data=df.to_csv(index=False).encode('utf-8'),
                    file_name=f"{selected_view}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                    mime="text/csv"
                )

                # Show column statistics for numeric columns
                numeric_cols = df.select_dtypes(include=['int64', 'float64']).columns
                if len(numeric_cols) > 0:
                    st.subheader("📊 Numeric Column Statistics")
                    st.dataframe(df[numeric_cols].describe(), use_container_width=True)
            else:
                st.warning(f"No data found in view: {selected_view}")

        except Exception as e:
            st.error(f"Error fetching view data: {str(e)}")

    elif mode == "CRUD Operations" and crud_operation:
        # Check if user has access to selected table
        if not can_access_table(role, selected_table):
            st.error(f"❌ Access denied: You don't have permission to access the '{selected_table}' table.")
            st.info(f"Your role ({role_name}) can only access: {', '.join(get_accessible_tables(role))}")
        else:
            st.header(f"📋 {crud_operation} Operations - {selected_table}")

            if crud_operation == "Create":
                create_record(selected_table)
            elif crud_operation == "Read":
                read_records(selected_table)
            elif crud_operation == "Update":
                update_record(selected_table)
            elif crud_operation == "Delete":
                delete_record(selected_table)

    elif mode == "Visualizations" and viz_option:
        # All visualization permissions already checked when building the menu
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
    st.markdown(f"*Dashboard with Role-Based Access Control | Logged in as: {role_name}*")

if __name__ == "__main__":
    main()
