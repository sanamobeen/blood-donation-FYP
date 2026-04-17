# 🩸 Blood Bank Application - Monorepo

A full-stack Blood Bank management system built with Django REST Framework (backend) and Flutter (frontend). This monorepo contains both the backend API and the mobile application in a single, well-organized repository.

---

## 🏗️ Project Structure

```
blood_bank/                      ← ✅ CLEAN MONOREPO STRUCTURE
├── backend/                     ← Django REST Framework Backend
│   ├── apps/
│   │   └── accounts/           ← User authentication app
│   │       ├── models.py       ← Custom User model
│   │       ├── views.py        ← API views
│   │       ├── serializers.py  ← DRF serializers
│   │       ├── urls.py         ← App URLs
│   │       └── migrations/     ← Database migrations
│   ├── blooddonation/          ← Django project settings
│   │   ├── settings.py         ← Project configuration
│   │   ├── urls.py             ← Main URL routes
│   │   └── wsgi.py             ← WSGI config
│   ├── media/                  ← User uploaded files
│   ├── venv/                   ← Python virtual environment
│   ├── manage.py               ← Django management script
│   └── requirements.txt        ← Python dependencies
│
├── frontend/                   ← Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart           ← App entry point
│   │   ├── screens/            ← UI screens
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   ├── home_page.dart
│   │   │   ├── find_donor.dart
│   │   │   ├── emergency_page.dart
│   │   │   └── ai_assistant_page.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart     ← Authentication API calls
│   │   │   └── api_config.dart       ← API configuration
│   │   └── models/            ← Data models
│   ├── android/               ← Android build files
│   ├── ios/                   ← iOS build files
│   ├── assets/                ← Images, fonts, etc.
│   └── pubspec.yaml           ← Flutter dependencies
│
├── docs/                      ← Documentation
│   └── HANDOVER.md            ← Detailed architecture documentation
│
├── .gitignore                 ← Git ignore rules
└── README.md                  ← This file
```

---

## 🚀 Quick Start

### Prerequisites

- **Backend:** Python 3.9+, Django 5.2+, DRF
- **Frontend:** Flutter 3.19+, Dart 3.3+
- **Database:** SQLite (development), PostgreSQL (production)

---

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run migrations:**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Start development server:**
   ```bash
   python manage.py runserver
   ```

Backend will run at: `http://127.0.0.1:8000`

---

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API configuration:**
   - Edit `lib/services/api_config.dart`
   - Set your backend API URL

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🔗 API Endpoints

### Authentication
- `POST /api/accounts/register/` - User registration
- `POST /api/accounts/login/` - User login (returns JWT token)
- `POST /api/token/refresh/` - Refresh access token
- `GET /api/accounts/profile/` - Get user profile

### Blood Bank Features
- `POST /api/donor/register/` - Register as blood donor
- `GET /api/donors/search/` - Find donors by blood group & location
- `POST /api/blood/request/` - Create blood request
- `GET /api/blood/requests/` - List blood requests
- `POST /api/donations/accept/` - Accept donation request

---

## 🏗️ Database Architecture

### Core Models

1. **User** (Custom user model)
   - Email-based authentication
   - Basic profile information

2. **Donor** (Optional profile)
   - Linked to User (OneToOne)
   - Blood group, availability, donation history

3. **BloodRequest**
   - Created by users seeking blood
   - Patient details, urgency level, units required

4. **Donation**
   - Links donors to blood requests
   - Tracks donation status and dates

For detailed database architecture, see [docs/HANDOVER.md](docs/HANDOVER.md)

---

## 🔧 Configuration

### Backend Settings

Edit `backend/blooddonation/settings.py`:

```python
DEBUG = True  # Set to False in production
SECRET_KEY = 'your-secret-key'
ALLOWED_HOSTS = ['127.0.0.1', 'localhost']
```

### Frontend Settings

Edit `frontend/lib/services/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://127.0.0.1:8000'; // Web
  // static const String baseUrl = 'https://your-api.com'; // Production
}
```

---

## 📱 Features

### User Features
- ✅ Email-based registration & login
- ✅ JWT authentication
- ✅ Profile management

### Donor Features
- ✅ Register as blood donor
- ✅ Set availability status
- ✅ Update blood group info
- ✅ View donation history

### Blood Request Features
- ✅ Create blood requests
- ✅ Set urgency levels (Low/Medium/High)
- ✅ Specify required units
- ✅ Search for donors by location & blood group

### Emergency Features
- ✅ Emergency blood request mode
- ✅ Quick donor matching
- ✅ Contact donors directly

### AI Assistant (Beta)
- ✅ Chat-based assistance
- ✅ Help with finding donors
- ✅ Guidance on blood donation process

---

## 🚢 Deployment

### Backend Deployment

1. Set up production database (PostgreSQL recommended)
2. Configure environment variables
3. Collect static files: `python manage.py collectstatic`
4. Use Gunicorn + Nginx for production server

### Frontend Deployment

1. Build release APK: `flutter build apk --release`
2. Upload to Google Play Store or distribute directly

---

## 📝 Environment Variables

Create `.env` file in `backend/`:

```env
DEBUG=True
SECRET_KEY=your-secret-key-here
DATABASE_URL=sqlite:///db.sqlite3
ALLOWED_HOSTS=127.0.0.1,localhost
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

---

## 🐛 Troubleshooting

### Backend Issues
- **Migration errors:** Delete `db.sqlite3` and re-run migrations
- **Import errors:** Ensure virtual environment is activated
- **CORS errors:** Check `CORS_ALLOWED_ORIGINS` in settings

### Frontend Issues
- **Connection refused:** Check API URL in `api_config.dart`
- **Build errors:** Run `flutter clean` then `flutter pub get`
- **Emulator issues:** Use `10.0.2.2` instead of `localhost` for Android

---

## 📚 Documentation

- [Database Architecture](docs/HANDOVER.md) - Detailed database design and relationships

---

## 👥 Contributing

This is a development project. Follow these guidelines:

1. Create feature branches from `main`
2. Write clean, documented code
3. Test thoroughly before committing
4. Update documentation as needed

---

## 📄 License

This project is developed for educational purposes.

---

**Status:** 🚧 Under Active Development

**Last Updated:** April 2026
