# Migration Guide: Custom User Model → Django Default User

## 🎯 What Changed

We've removed the custom `MyUser` model and migrated to Django's built-in `User` model with an extended `UserProfile`.

### **Old Structure:**
- Custom `MyUser` model with all fields in one table
- Donor model referenced user by ID

### **New Structure:**
- Django's default `User` model (username, email, first_name, last_name, etc.)
- `UserProfile` model with extended fields (phone, gender, location, blood_group)
- `Donor` model properly linked via ForeignKey to User

## 📊 New Database Schema

### **User Table (Django default)**
- `id` (Primary Key)
- `username` (Unique)
- `email` (Unique)
- `first_name`
- `last_name`
- `password` (Hashed)
- `is_staff`, `is_active`, `is_superuser`
- `date_joined`

### **UserProfile Table (Extended fields)**
- `id` (Primary Key)
- `user` (ForeignKey → User, OneToOne)
- `phone` (Required)
- `gender` (Optional)
- `province` (Optional)
- `district` (Optional)
- `local_level` (Optional)
- `date_of_birth` (Optional)
- `blood_group` (Optional)
- `created_at`, `updated_at`

### **Donor Table**
- `id` (Primary Key)
- `user` (ForeignKey → User, OneToOne)
- `is_available`
- `last_donation_date`
- `total_donations`
- `created_at`

## 🚀 Migration Steps

### **Step 1: Backup Current Database**
```bash
# Export current data
mysqldump -u root -p blood_donor_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

### **Step 2: Drop Old Tables**
```bash
# Access MySQL
mysql -u root -p blood_donor_db

# Drop old custom tables
DROP TABLE IF EXISTS accounts_emailverification;
DROP TABLE IF EXISTS accounts_passwordreset;
DROP TABLE IF EXISTS accounts_donor;
DROP TABLE IF EXISTS accounts_myuser;
```

### **Step 3: Run New Migrations**
```bash
# Navigate to backend
cd D:\FYP\blood-donation-FYP\backend

# Activate virtual environment
venv\Scripts\activate

# Create new migrations
python manage.py makemigrations accounts

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
```

### **Step 4: Update Frontend (No Changes Needed!)**
Your Flutter frontend doesn't need any changes! The API endpoints remain the same:
- Registration: `POST /api/accounts/register/`
- Login: `POST /api/accounts/login/`
- Profile: `GET /api/accounts/profile/`

## 📝 Updated Registration Fields

### **Required Fields:**
- `email` (Used as username)
- `phone`
- `password`
- `confirm_password`

### **Optional Fields (Auto-filled if not provided):**
- `first_name`, `last_name` (Default: empty)
- `gender` (Default: "Other")
- `province` (Default: "Punjab")
- `district` (Default: "Lahore")
- `local_level` (Default: "Urban")
- `date_of_birth` (Default: null)
- `blood_group` (Default: null)

## 🧪 Testing

### **Test Registration:**
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

### **Test Login:**
```bash
curl -X POST http://localhost:8001/api/accounts/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123"
  }'
```

## ✅ Benefits of This Change

1. **Simpler Authentication:** Uses Django's built-in auth system
2. **Better Security:** Leverages Django's security features
3. **Easier Maintenance:** Less custom code to maintain
4. **Standard Practice:** Follows Django best practices
5. **Admin Panel:** Works seamlessly with Django admin
6. **Future Compatibility:** Easier to upgrade Django versions

## 🔧 Admin Panel Access

After migration, you can access the Django admin panel:
- URL: `http://localhost:8001/admin/`
- Login with your superuser credentials
- Manage Users, UserProfiles, and Donors from the interface

## 🐛 Troubleshooting

### **Issue: Migration errors**
```bash
# Reset migrations
python manage.py migrate accounts zero
python manage.py makemigrations accounts
python manage.py migrate
```

### **Issue: Authentication not working**
```bash
# Clear session data
python manage.py clearsessions
```

### **Issue: Admin panel not accessible**
```bash
# Create new superuser
python manage.py createsuperuser
```

## 📋 Files Modified

1. ✅ `blooddonation/settings.py` - Removed AUTH_USER_MODEL
2. ✅ `apps/accounts/models.py` - Replaced MyUser with UserProfile
3. ✅ `apps/accounts/serializers.py` - Updated for new User model
4. ✅ `apps/accounts/views.py` - Updated to use Django User
5. ✅ `apps/accounts/authentication.py` - Removed (not needed)

## 🎉 Migration Complete!

Your backend now uses Django's default User model while maintaining all the functionality you had before. The frontend doesn't need any changes!
