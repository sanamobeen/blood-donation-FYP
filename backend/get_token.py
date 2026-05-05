#!/usr/bin/env python
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blooddonation.settings')
django.setup()

from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model

User = get_user_model()

print("=== Generating JWT Token ===\n")

# Get first user
user = User.objects.first()
if user:
    refresh = RefreshToken.for_user(user)

    print(f"✅ User Email: {user.email}")
    print(f"✅ User ID: {user.id}")
    print(f"\n🔑 Access Token (copy this):")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"{refresh.access_token}")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"\n📝 Full Authorization Header:")
    print(f"Authorization: Bearer {refresh.access_token}")
    print(f"\n🔄 Refresh Token:")
    print(f"{refresh}")

    print(f"\n" + "="*60)
    print(f"📋 Usage Example:")
    print(f"="*60)
    print(f"curl -X POST http://localhost:8000/api/blood-requests/create/ \\")
    print(f"  -H \"Authorization: Bearer {refresh.access_token}\" \\")
    print(f"  -H \"Content-Type: application/json\" \\")
    print(f"  -d '{{'")
    print(f"    \"patient_name\": \"John Doe\",")
    print(f"    \"emergency_contact\": \"0300-1234567\",")
    print(f"    \"blood_group\": 1,")
    print(f"    \"gender\": 1,")
    print(f"    \"province\": 1,")
    print(f"    \"district\": 1,")
    print(f"    \"local_level\": 1,")
    print(f"    \"units_required\": 2,")
    print(f"    \"required_date\": \"2026-05-15\",")
    print(f"    \"required_time\": \"14:30\",")
    print(f"    \"urgency_level\": \"high\",")
    print(f"    \"city\": \"Lahore\",")
    print(f"    \"hospital_name\": \"General Hospital\",")
    print(f"    \"case\": \"Test request\"")
    print(f"  }}'")
    print(f"\"")

else:
    print("❌ No users found in database!")
    print("\n📝 Create a user first:")
    print("curl -X POST http://localhost:8000/api/auth/register/ \\")
    print("  -H \"Content-Type: application/json\" \\")
    print("  -d '{")
    print('    "email": "test@example.com",')
    print('    "password": "TestPass123!",')
    print('    "confirm_password": "TestPass123!",')
    print('    "full_name": "Test User",')
    print('    "phone": "03001234567",')
    print('    "province": 1,')
    print('    "district": 1,')
    print('    "local_level": 1,')
    print('    "gender": 1')
    print("  }'")
