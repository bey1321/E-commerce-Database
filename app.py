"""
Streamlit + SQLAlchemy Dashboard
Complete CRUD Operations and Advanced Visualizations
"""

import streamlit as st
import sqlite3
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, date
from sqlalchemy import create_engine, text, inspect
import re

# =====================================================
# DATABASE CONNECTION & HELPER FUNCTIONS
# =====================================================

DATABASE_PATH = "database.db"

@st.cache_resource
def get_engine():
    """Create and cache SQLAlchemy engine"""
    return create_engine(f"sqlite:///{DATABASE_PATH}")

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
        return sorted(inspector.get_table_names())
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
    numeric_types = ['INTEGER', 'REAL', 'FLOAT', 'NUMERIC', 'DECIMAL']
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

def extract_check_constraint_values(column_info):
    """Extract allowed values from CHECK constraint (e.g., CHECK(Gender IN ('Male', 'Female')))"""
    try:
        # Get the column definition from schema
        engine = get_engine()
        table_name = column_info.get('table')
        col_name = column_info.get('name')
        
        # Try to get constraint from sqlite_master
        query = text(f"""
            SELECT sql FROM sqlite_master 
            WHERE type='table' AND name=:table_name
        """)
        
        with engine.connect() as conn:
            result = conn.execute(query, {'table_name': table_name})
            row = result.fetchone()
            
            if row and row[0]:
                sql = row[0]
                # Look for CHECK constraint pattern like: Gender IN ('Male', 'Female')
                import re
                pattern = rf"{col_name}\s+[^,\)]*CHECK\s*\([^IN]*IN\s*\(([^)]+)\)"
                match = re.search(pattern, sql, re.IGNORECASE)
                
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
                         len(pk_columns) == 1)
            
            if is_auto_id:
                next_id = get_next_id(table_name, col_name)
                st.info(f"🔢 {col_name} (Auto-generated): **{next_id}**")
                continue

            # Check for domain constraints (CHECK IN constraint)
            col_info = {'table': table_name, 'name': col_name}
            allowed_values = extract_check_constraint_values(col_info)

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
                if 'REAL' in str(col_type).upper() or 'FLOAT' in str(col_type).upper():
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
        st.dataframe(df, width='stretch', height=400)
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
                col_info = {'table': table_name, 'name': col_name}
                allowed_values = extract_check_constraint_values(col_info)

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
                            date_val = datetime.strptime(str(current_value), '%Y-%m-%d').date()
                        except:
                            date_val = None
                    else:
                        date_val = None

                    value = st.date_input(f"{col_name}", value=date_val, key=f"update_{col_name}_{selected_index}")
                    if value:
                        form_data[col_name] = value.strftime('%Y-%m-%d')
                elif is_numeric_column(col_type):
                    if 'REAL' in str(col_type).upper() or 'FLOAT' in str(col_type).upper():
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
    st.dataframe(df, width='stretch', height=300)

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
            df['Age'] = df['DOB'].apply(lambda x: (datetime.now() - datetime.strptime(x, '%Y-%m-%d')).days // 365)

            fig = px.histogram(df, x='Age', nbins=20, title='Customer Age Distribution',
                             labels={'Age': 'Age (years)', 'count': 'Number of Customers'})
            fig.update_traces(marker_color='lightblue', marker_line_color='darkblue', marker_line_width=1.5)
            st.plotly_chart(fig, width='stretch')

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
            SELECT RegistrationDate, COUNT(*) as CustomerCount
            FROM customer
            WHERE RegistrationDate IS NOT NULL
            GROUP BY RegistrationDate
            ORDER BY RegistrationDate
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            df['RegistrationDate'] = pd.to_datetime(df['RegistrationDate'])
            df['CumulativeCustomers'] = df['CustomerCount'].cumsum()

            fig = px.line(df, x='RegistrationDate', y='CumulativeCustomers',
                         title='Cumulative Customer Growth',
                         labels={'RegistrationDate': 'Date', 'CumulativeCustomers': 'Total Customers'})
            fig.update_traces(line_color='green', line_width=3)
            st.plotly_chart(fig, width='stretch')

            st.metric("Total Customers", df['CumulativeCustomers'].iloc[-1])
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
            SELECT p.ProductName, pa.SalesCount, pa.LastMonthSales, pa.IsBestSeller
            FROM product p
            JOIN productAnalytics pa ON p.ProductID = pa.ProductID
            ORDER BY pa.SalesCount DESC
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='ProductName', y='SalesCount',
                        title='Product Sales Count',
                        labels={'ProductName': 'Product', 'SalesCount': 'Total Sales'},
                        color='IsBestSeller',
                        color_discrete_map={0: 'lightblue', 1: 'gold'})
            st.plotly_chart(fig, width='stretch')

            col1, col2 = st.columns(2)
            col1.metric("Total Sales", df['SalesCount'].sum())
            col2.metric("Best Sellers", len(df[df['IsBestSeller'] == 1]))
        else:
            st.info("No product analytics data available")
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
            st.plotly_chart(fig, width='stretch')

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
            st.plotly_chart(fig, width='stretch')

            st.dataframe(df, width='stretch')
        else:
            st.info("No payment data available")
    except Exception as e:
        st.error(f"Error generating payment status chart: {str(e)}")

def viz_delivery_status():
    """Delivery Status Breakdown"""
    st.subheader("🚚 Delivery Status Overview")

    try:
        engine = get_engine()
        query = text("""
            SELECT DeliveryStatus, COUNT(*) as Count
            FROM delivery
            GROUP BY DeliveryStatus
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='DeliveryStatus', y='Count',
                        title='Delivery Status Distribution',
                        labels={'DeliveryStatus': 'Status', 'Count': 'Number of Deliveries'},
                        color='Count',
                        color_continuous_scale='Viridis')
            st.plotly_chart(fig, width='stretch')
        else:
            st.info("No delivery data available")
    except Exception as e:
        st.error(f"Error generating delivery status chart: {str(e)}")

def viz_discount_usage():
    """Discount Usage Analysis"""
    st.subheader("🎁 Discount Usage Analysis")

    try:
        engine = get_engine()
        query = text("""
            SELECT d.DiscountType, d.DiscountValue, COUNT(pd.ProductID) as ProductsWithDiscount
            FROM discount d
            LEFT JOIN productDiscount pd ON d.DiscountID = pd.DiscountID
            GROUP BY d.DiscountID, d.DiscountType, d.DiscountValue
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            fig = px.bar(df, x='DiscountType', y='ProductsWithDiscount',
                        title='Products by Discount Type',
                        labels={'DiscountType': 'Discount Type', 'ProductsWithDiscount': 'Number of Products'},
                        color='DiscountValue',
                        color_continuous_scale='Oranges')
            st.plotly_chart(fig, width='stretch')
        else:
            st.info("No discount data available")
    except Exception as e:
        st.error(f"Error generating discount usage chart: {str(e)}")

def viz_geographical_distribution():
    """Geographical Distribution"""
    st.subheader("🌍 Geographical Distribution")

    try:
        engine = get_engine()
        query = text("""
            SELECT
                a.Street,
                c.CityName,
                s.StateName,
                co.CountryName,
                a.Latitude,
                a.Longitude
            FROM address a
            LEFT JOIN addressCity ac ON a.AddressID = ac.AddressID
            LEFT JOIN city c ON ac.CityID = c.CityID
            LEFT JOIN cityState cs ON c.CityID = cs.CityID
            LEFT JOIN state s ON cs.StateID = s.StateID
            LEFT JOIN stateCountry sc ON s.StateID = sc.StateID
            LEFT JOIN country co ON sc.CountryID = co.CountryID
        """)

        with engine.connect() as conn:
            df = pd.read_sql(query, conn)

        if not df.empty:
            # Count by country
            country_counts = df['CountryName'].value_counts().reset_index()
            country_counts.columns = ['Country', 'Count']

            fig = px.bar(country_counts, x='Country', y='Count',
                        title='Address Distribution by Country',
                        labels={'Country': 'Country', 'Count': 'Number of Addresses'},
                        color='Count',
                        color_continuous_scale='Blues')
            st.plotly_chart(fig, width='stretch')

            # Show map if coordinates available
            map_df = df[df['Latitude'].notna() & df['Longitude'].notna()]
            if not map_df.empty:
                fig_map = px.scatter_geo(map_df,
                                        lat='Latitude',
                                        lon='Longitude',
                                        hover_name='CityName',
                                        title='Address Locations on Map')
                st.plotly_chart(fig_map, width='stretch')
        else:
            st.info("No geographical data available")
    except Exception as e:
        st.error(f"Error generating geographical distribution: {str(e)}")

# =====================================================
# MAIN APPLICATION
# =====================================================

def main():
    st.set_page_config(
        page_title="Database Dashboard",
        page_icon="📊",
        layout="wide",
        initial_sidebar_state="expanded"
    )

    st.title("🗄️ Database Management Dashboard")
    st.markdown("---")

    # Sidebar
    with st.sidebar:
        st.header("⚙️ Navigation")

        # Get all tables
        tables = get_all_tables()

        if not tables:
            st.error("No tables found in database!")
            return

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
                    "Product Sales Analysis",
                    "Order Amount Distribution",
                    "Payment Status Breakdown",
                    "Delivery Status Overview",
                    "Discount Usage Analysis",
                    "Geographical Distribution"
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
        elif viz_option == "Product Sales Analysis":
            viz_product_sales()
        elif viz_option == "Order Amount Distribution":
            viz_order_distribution()
        elif viz_option == "Payment Status Breakdown":
            viz_payment_status()
        elif viz_option == "Delivery Status Overview":
            viz_delivery_status()
        elif viz_option == "Discount Usage Analysis":
            viz_discount_usage()
        elif viz_option == "Geographical Distribution":
            viz_geographical_distribution()

    # Footer
    st.markdown("---")
    st.markdown("*Dashboard built with Streamlit + SQLAlchemy | Secure CRUD with parameterized queries*")

if __name__ == "__main__":
    main()
