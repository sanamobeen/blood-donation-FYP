# Blood Donation Backend - Setup and Run Guide

## Prerequisites
- Python 3.8+
- MySQL database
- Virtual environment

## Setup Instructions

### 1. Navigate to Backend Directory
```bash
cd D:\FYP\blood-donation-FYP\backend
```

### 2. Activate Virtual Environment
```bash
# Windows
venv\Scripts\activate

# If activation fails, try:
venv\Scripts\activate.bat
```

### 3. Install Dependencies (if needed)
```bash
pip install -r requirements.txt
```

### 4. Database Setup
Make sure MySQL is running and create the database:

```sql
CREATE DATABASE blood_donor_db;
```

Update database credentials in `blooddonation/settings.py` if needed:
```python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": "blood_donor_db",
        "USER": "root",           # Your MySQL username
        "PASSWORD": "password",    # Your MySQL password
        "HOST": "localhost",
        "PORT": "3306",
    }
}
```

### 5. Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### 6. Create Superuser (Optional)
```bash
python manage.py createsuperuser
```

### 7. Start the Server
```bash
# Run on port 8001 (as configured in frontend)
python manage.py runserver 8001

# Or default port 8000
python manage.py runserver
```

### 8. Test the Backend
Open browser and visit:
- Admin Panel: http://localhost:8001/admin/
- API Root: http://localhost:8001/api/
- Test Registration: http://localhost:8001/api/accounts/register/

## API Endpoints

### Authentication Endpoints
- `POST /api/accounts/register/` - User registration
- `POST /api/accounts/login/` - User login  
- `POST /api/accounts/logout/` - User logout
- `GET /api/accounts/profile/` - Get user profile
- `PUT /api/accounts/profile/` - Update user profile

### Password Reset
- `POST /api/accounts/forgot-password/` - Request password reset
- `POST /api/accounts/reset-password/` - Reset password with token

## Testing Registration with Postman/curl

```bash
curl -X POST http://localhost:8001/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "phone": "+923001234567",
    "password": "Test@123",
    "confirm_password": "Test@123",
    "gender": "Male",
    "province": "Punjab",
    "district": "Lahore",
    "local_level": "Model Town",
    "date_of_birth": "1995-01-01",
    "blood_group": "A+"
  }'
```

## Testing Login
```bash
curl -X POST http://localhost:8001/api/accounts/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123"
  }'
```

## Common Issues

### Issue: Port already in use
```bash
# Kill process on port 8001 (Windows)
netstat -ano | findstr :8001
taskkill /PID <PID> /F
```

### Issue: Database connection error
- Make sure MySQL is running
- Check database credentials in settings.py
- Ensure database `blood_donor_db` exists

### Issue: Migration errors
```bash
# Reset migrations (WARNING: Deletes data)
python manage.py migrate accounts zero
python manage.py migrate
```

## Development Mode Features

Currently enabled for development:
- DEBUG = True
- CORS_ALLOW_ALL_ORIGINS = True  
- Rate limiting disabled
- Detailed error messages

Remember to disable these in production!

## Production Checklist

Before deploying:
- [ ] Set DEBUG = False
- [ ] Set strong SECRET_KEY
- [ ] Configure ALLOWED_HOSTS
- [ ] Set up production database
- [ ] Configure email service
- [ ] Enable HTTPS
- [ ] Set up static file serving
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up logging and monitoring
