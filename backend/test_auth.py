"""
Updated test script for registration and login with Django default User model
Tests with only: Full Name, Phone, Email, Password, Confirm Password
"""

import requests
import json

BASE_URL = "http://localhost:8001/api/accounts"

def test_registration():
    """Test registration with minimal fields"""
    print("Testing Registration...")

    registration_data = {
        "email": "test@example.com",
        "phone": "+923001234567",
        "password": "Test@123",
        "confirm_password": "Test@123"
        # Other fields are optional and will use defaults
    }

    try:
        response = requests.post(
            f"{BASE_URL}/register/",
            json=registration_data,
            timeout=10
        )

        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")

        if response.status_code == 201:
            print("✅ Registration Successful!")
            return response.json()
        else:
            print("❌ Registration Failed!")
            return None

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def test_login():
    """Test login with email and password"""
    print("\nTesting Login...")

    login_data = {
        "email": "test@example.com",
        "password": "Test@123"
    }

    try:
        response = requests.post(
            f"{BASE_URL}/login/",
            json=login_data,
            timeout=10
        )

        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")

        if response.status_code == 200:
            print("✅ Login Successful!")
            return response.json()
        else:
            print("❌ Login Failed!")
            return None

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

def test_duplicate_registration():
    """Test that duplicate email fails"""
    print("\nTesting Duplicate Registration...")

    registration_data = {
        "email": "test@example.com",  # Same email as before
        "phone": "+923001234568",
        "password": "Test@456",
        "confirm_password": "Test@456"
    }

    try:
        response = requests.post(
            f"{BASE_URL}/register/",
            json=registration_data,
            timeout=10
        )

        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")

        if response.status_code == 400:
            print("✅ Duplicate correctly rejected!")
            return True
        else:
            print("❌ Duplicate should have been rejected!")
            return False

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def test_registration_with_extended_fields():
    """Test registration with extended fields"""
    print("\nTesting Registration with Extended Fields...")

    registration_data = {
        "email": "donor@example.com",
        "phone": "+923001234569",
        "password": "Test@123",
        "confirm_password": "Test@123",
        "first_name": "Blood",
        "last_name": "Donor",
        "gender": "Male",
        "province": "Punjab",
        "district": "Lahore",
        "blood_group": "A+",
        "date_of_birth": "1995-01-01"
    }

    try:
        response = requests.post(
            f"{BASE_URL}/register/",
            json=registration_data,
            timeout=10
        )

        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")

        if response.status_code == 201:
            print("✅ Extended Registration Successful!")
            return response.json()
        else:
            print("❌ Extended Registration Failed!")
            return None

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return None

if __name__ == "__main__":
    print("=" * 60)
    print("Blood Donation Backend - Auth Tests (Django Default User)")
    print("=" * 60)

    # Test 1: Basic Registration
    reg_result = test_registration()

    # Test 2: Login
    login_result = test_login()

    # Test 3: Duplicate registration
    duplicate_result = test_duplicate_registration()

    # Test 4: Extended registration
    extended_result = test_registration_with_extended_fields()

    print("\n" + "=" * 60)
    print("Test Summary:")
    print("=" * 60)
    print(f"Basic Registration: {'✅ PASS' if reg_result else '❌ FAIL'}")
    print(f"Login: {'✅ PASS' if login_result else '❌ FAIL'}")
    print(f"Duplicate Check: {'✅ PASS' if duplicate_result else '❌ FAIL'}")
    print(f"Extended Registration: {'✅ PASS' if extended_result else '❌ FAIL'}")
    print("\n🎉 All tests completed!")
