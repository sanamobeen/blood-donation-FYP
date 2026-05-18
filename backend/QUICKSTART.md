# 🚀 Quick Start Guide - Blood Donation Backend

## ✅ Custom User Model Removed!

Your backend now uses **Django's default User model** instead of the custom `MyUser` model.

## 🎯 What You Need to Do

### **Step 1: Clean Up Old Database**
```bash
# Navigate to backend
cd D:\FYP\blood-donation-FYP\backend

# Activate virtual environment
venv\Scripts\activate

# Drop old custom tables (MySQL)
mysql -u root -p blood_donor_db
```

**In MySQL:**
```sql
DROP TABLE IF EXISTS accounts_emailverification;
DROP TABLE IF EXISTS accounts_passwordreset;
DROP TABLE IF EXISTS accounts_donor;
DROP TABLE IF EXISTS accounts_myuser;
exit;
```

### **Step 2: Run New Migrations**
```bash
# Create new migrations
python manage.py makemigrations accounts

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
```

### **Step 3: Start Server**
```bash
python manage.py runserver 8001
```

### **Step 4: Test Your Backend**
```bash
# Install requests if needed
pip install requests

# Run test script
python test_auth.py
```

## 🧪 Test Registration (Your Frontend Fields)

```bash
curl -X POST http://localhost:8001/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phone": "+923001234567",
    "password": "Test@123",
    "confirm_password": "Test@123"
  }'
```

## ✨ What's Better Now?

1. **Simpler:** Uses Django's built-in User model
2. **Standard:** Follows Django best practices
3. **Secure:** Leverages Django's security features
4. **Admin Panel:** Works with Django admin perfectly
5. **Frontend:** No changes needed - same API endpoints!

## 📊 New Database Structure

**User Table (Django Default):**
- `id`, `username`, `email`, `password`, etc.

**UserProfile Table (Extended Fields):**
- `user` (link to User), `phone`, `gender`, `province`, `district`, `blood_group`, etc.

**Donor Table:**
- `user` (link to User), `is_available`, `last_donation_date`, etc.

## 🔧 Frontend (No Changes Needed!)

Your Flutter app continues to work exactly the same:
- Registration: 5 fields (Full Name, Phone, Email, Password, Confirm Password)
- Login: 2 fields (Email, Password)
- Same API endpoints: `/api/accounts/register/`, `/api/accounts/login/`

## 🎉 Done!

Your backend is now simpler and more maintainable while keeping all functionality!
