# Security Setup Guide

## Environment Configuration

This project now uses environment variables to store sensitive database credentials instead of hardcoding them in source files.

## Quick Setup

### 1. Copy the example environment file
```bash
cp .env.example .env
```

### 2. Edit `.env` with your actual credentials
```bash
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_actual_password_here
MYSQL_DATABASE=ecommerce_db
```

### 3. Install dependencies (includes python-dotenv)
```bash
pip install -r requirements.txt
```

### 4. Run the application
```bash
streamlit run app.py
```

## Important Security Notes

### ⚠️ Never Commit `.env` to Version Control
The `.env` file contains sensitive credentials and is automatically excluded via `.gitignore`.

**Always verify before committing:**
```bash
git status
# .env should NOT appear in the list
```

### 🔒 Production Deployment Checklist
- [ ] Change all default passwords in `security/userAccountCreation.sql`
- [ ] Use strong passwords (minimum 12 characters, mixed case, numbers, special chars)
- [ ] Update `.env` with production credentials
- [ ] Restrict MySQL user access to specific IP addresses
- [ ] Enable MySQL SSL/TLS connections
- [ ] Regularly rotate passwords
- [ ] Review audit logs in `security_log` table

### 📝 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `MYSQL_HOST` | MySQL server hostname | `localhost` or `192.168.1.100` |
| `MYSQL_PORT` | MySQL server port | `3306` (default) |
| `MYSQL_USER` | Root/admin MySQL user | `root` |
| `MYSQL_PASSWORD` | MySQL password | `YourSecurePassword123!` |
| `MYSQL_DATABASE` | Database name | `ecommerce_db` |

### 🔑 User Account Passwords

User account passwords are set in `security/userAccountCreation.sql`. The default passwords in that file are **for development only**.

**To change passwords:**
1. Edit `security/userAccountCreation.sql`
2. Replace passwords with strong values
3. Run the SQL file: `mysql -u root -p ecommerce_db < security/userAccountCreation.sql`
4. Update the passwords in the dashboard login screen

### 🛡️ Additional Security Features

This dashboard includes:
- SQL injection prevention (parameterized queries)
- Role-based access control (RBAC)
- Audit trail logging
- Security event logging
- Data masking for sensitive fields
- Session-based authentication

## Troubleshooting

### "Can't connect to MySQL"
- Check `.env` file exists and has correct credentials
- Verify MySQL service is running
- Test connection: `mysql -h localhost -u root -p`

### "Access denied"
- Double-check password in `.env`
- Ensure MySQL user has proper privileges
- Check if user exists: `SELECT User, Host FROM mysql.user;`

### "python-dotenv not found"
```bash
pip install python-dotenv
# or
pip install -r requirements.txt
```

## Files Modified for Security

### New Files
- `.env` - Your local credentials (DO NOT COMMIT)
- `.env.example` - Template for credentials
- `.gitignore` - Excludes sensitive files
- `SECURITY_SETUP.md` - This guide

### Modified Files
- `app.py` - Now loads credentials from environment variables
- `requirements.txt` - Added python-dotenv dependency
- `README.md` - Removed hardcoded credentials
- `Documentation/*.md` - Removed credential examples

## Best Practices

1. **Never share your `.env` file**
2. **Use different passwords for each environment** (dev, staging, production)
3. **Rotate passwords regularly** (every 90 days minimum)
4. **Use password managers** to generate and store strong passwords
5. **Monitor the `security_log` table** for suspicious activity
6. **Limit database user privileges** to only what's needed
7. **Keep dependencies updated** for security patches

---

**Need Help?** Check the main [README.md](README.md) or [Database_Security_Implementation_Report.md](Documentation/Database_Security_Implementation_Report.md)
