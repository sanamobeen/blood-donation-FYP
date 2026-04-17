# 🩸 Blood Bank Application - Project Handover

## 📋 Project Overview
A full-stack Blood Bank management system that connects blood donors with recipients. Built with Django REST Framework backend and React frontend.

---

## 🏗️ DATABASE ARCHITECTURE

### 1. USER TABLE (Single Profile System)
```python
User
-----
id (PK, AutoField)
first_name (CharField)
last_name (CharField)
email (EmailField, unique=True)
password (CharField, hashed)
phone (CharField)
city (CharField)
gender (CharField, optional)
created_at (DateTimeField, auto_now_add=True)
updated_at (DateTimeField, auto_now=True)
```

**Rule:** This is the ONLY profile in the system. Every person registers here once.

---

### 2. DONOR TABLE (Optional Role)
```python
Donor
------
id (PK, AutoField)
user_id (OneToOneField → User)
blood_group (CharField, choices=BLOOD_GROUPS)
is_available (BooleanField, default=True)
last_donation_date (DateField, nullable=True)
total_donations (IntegerField, default=0)
created_at (DateTimeField, auto_now_add=True)
```

**Rule:** Created ONLY when user clicks "Register as Donor". One user → one donor profile.

---

### 3. BLOOD REQUEST TABLE
```python
BloodRequest
-------------
id (PK, AutoField)
user_id (ForeignKey → User, related_name='blood_requests')
patient_name (CharField)
emergency_contact (CharField)
blood_group (CharField, choices=BLOOD_GROUPS)
units_required (IntegerField)
urgency_level (CharField, choices=URGENCY_LEVELS)
city (CharField)
hospital_name (CharField)
status (CharField, choices=STATUS_CHOICES, default='pending')
created_at (DateTimeField, auto_now_add=True)
updated_at (DateTimeField, auto_now=True)
```

**Rule:** Used when user clicks "Request Blood". One user can make multiple requests.

---

### 4. DONATION TABLE (Junction Table)
```python
Donation
---------
id (PK, AutoField)
donor_id (ForeignKey → Donor, related_name='donations')
request_id (ForeignKey → BloodRequest, related_name='donations')
status (CharField, choices=DONATION_STATUS, default='pending')
donation_date (DateField, nullable=True)
units_donated (IntegerField, default=1)
created_at (DateTimeField, auto_now_add=True)
updated_at (DateTimeField, auto_now=True)
```

**Rule:** Connector table that links donors to blood requests they accept.

---

## 🔗 DATABASE RELATIONSHIPS

```
User (1) ────── (1) Donor
 │
 │
 └────── (M) BloodRequest

Donor (1) ────── (M) Donation

BloodRequest (1) ────── (M) Donation
```

**Relationship Summary:**
- User ↔ Donor: OneToOne (A user can have at most one donor profile)
- User → BloodRequest: OneToMany (A user can make multiple blood requests)
- Donor → Donation: OneToMany (A donor can make multiple donations)
- BloodRequest → Donation: OneToMany (A request can receive donations from multiple donors)

---

## 📱 APPLICATION FLOW

### Post-Login Dashboard
After successful login, user sees 3 main options:

```
┌─────────────────────────────────────┐
│     BLOOD BANK DASHBOARD           │
├─────────────────────────────────────┤
│                                     │
│  🔍 FIND DONOR                      │
│  🧍 REQUEST BLOOD                   │
│  🩸 REGISTER AS DONOR               │
│                                     │
└─────────────────────────────────────┘
```

---

### 🔍 FEATURE 1: FIND DONOR
**Purpose:** Search for available blood donors in your area

**User Input:**
- Blood Group (A+, A-, B+, B-, AB+, AB-, O+, O-)
- City

**Backend Logic:**
```python
# Query: Find available donors matching blood group and city
donors = Donor.objects.filter(
    blood_group=requested_blood_group,
    city=requested_city,
    is_available=True
)
```

**Returns:** List of available donors with contact info

---

### 🧍 FEATURE 2: REQUEST BLOOD
**Purpose:** Create a blood request for a patient

**User Input:**
- Patient Name
- Emergency Contact Number
- Blood Group Required
- Units Required
- Urgency Level (Low/Medium/High)
- City
- Hospital Name

**Backend Logic:**
```python
# Create blood request
BloodRequest.objects.create(
    user_id=request.user,
    patient_name=patient_name,
    emergency_contact=emergency_contact,
    blood_group=blood_group,
    units_required=units_required,
    urgency_level=urgency_level,
    city=city,
    hospital_name=hospital_name
)
```

**Result:** New blood request created with status='pending'

---

### 🩸 FEATURE 3: REGISTER AS DONOR
**Purpose:** User registers themselves as a blood donor

**User Input:**
- Blood Group
- Availability Status (Available/Not Available)

**Backend Logic:**
```python
# Check if donor profile already exists
if Donor.objects.filter(user_id=request.user).exists():
    return Error("Already registered as donor")

# Create donor profile
Donor.objects.create(
    user_id=request.user,
    blood_group=blood_group,
    is_available=is_available
)
```

**Result:** Donor profile created, user can now donate blood

---

## ❌ ARCHITECTURE ANTI-PATTERNS (DO NOT DO)

❌ **DO NOT** store `blood_group` in User table
❌ **DO NOT** create separate "donor accounts" and "taker accounts"
❌ **DO NOT** duplicate users across multiple tables
❌ **DO NOT** create donation records without linking to both donor and request

---

## ✅ WHY THIS ARCHITECTURE IS PERFECT

✔ **Single Identity:** One user = one identity in the system
✔ **Role-Based:** Donor is an optional role, not a separate account
✔ **Clean Separation:** User, Donor, Request, and Donation data are properly separated
✔ **Scalable:** Easy to add new features (blood camps, notifications, etc.)
✔ **Industry Standard:** Matches real-world blood bank applications
✔ **Data Integrity:** Foreign keys ensure no orphaned records
✔ **Audit Trail:** created_at/updated_at on all tables

---

## 🔧 CHOICES & FIELD DEFINITIONS

### Blood Group Choices
```python
BLOOD_GROUPS = [
    ('A+', 'A Positive'),
    ('A-', 'A Negative'),
    ('B+', 'B Positive'),
    ('B-', 'B Negative'),
    ('AB+', 'AB Positive'),
    ('AB-', 'AB Negative'),
    ('O+', 'O Positive'),
    ('O-', 'O Negative'),
]
```

### Urgency Level Choices
```python
URGENCY_LEVELS = [
    ('low', 'Low'),
    ('medium', 'Medium'),
    ('high', 'High - Critical'),
]
```

### Blood Request Status
```python
REQUEST_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('partially_fulfilled', 'Partially Fulfilled'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
]
```

### Donation Status
```python
DONATION_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('rejected', 'Rejected'),
    ('completed', 'Completed'),
]
```

---

## 🚀 NEXT STEPS FOR IMPLEMENTATION

### Phase 1: Backend Setup
1. Create Django models as per above schema
2. Run migrations: `python manage.py makemigrations` & `python manage.py migrate`
3. Create Django REST Framework serializers
4. Build API endpoints for:
   - `/api/register/` - User registration
   - `/api/login/` - User login (JWT/Session)
   - `/api/donor/register/` - Register as donor
   - `/api/blood/request/` - Create blood request
   - `/api/donors/search/` - Find donors
   - `/api/donations/accept/` - Accept donation request

### Phase 2: Frontend Development
1. Create React app with routing
2. Build authentication pages (Login/Register)
3. Build dashboard with 3 main features
4. Connect frontend to backend APIs
5. Add form validation and error handling

### Phase 3: Additional Features (Future)
- Email notifications for blood requests
- SMS alerts for urgent requests
- Donation history tracking
- Donor badges/certificates
- Blood donation camp management
- Admin dashboard for monitoring

---

## 📝 IMPORTANT NOTES

1. **Authentication:** Use JWT or Django Session authentication
2. **Passwords:** Must be hashed using Django's built-in password hashing
3. **Authorization:** Only authenticated users can create requests or register as donors
4. **Data Privacy:** Phone numbers and contact info should be visible only to relevant parties
5. **Input Validation:** Add frontend and backend validation for all forms

---

## 🎯 SUCCESS CRITERIA

✅ User can register and login
✅ User can register as a donor
✅ User can search for donors by blood group and city
✅ User can create blood requests
✅ Donors can accept donation requests
✅ System tracks donation history
✅ All data relationships are maintained correctly

---

**Project Status:** Architecture Complete ✅
**Ready for:** Implementation Phase 🚀
