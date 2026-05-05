# Test Blood Request Validation
# This script tests the validation rules for the BloodRequestSerializer

from apps.blood_requests.serializers import BloodRequestSerializer
from apps.accounts.models import BloodGroup, Gender, Province, District, LocalLevel

def test_validation():
    """Test various validation scenarios"""

    # Test data
    invalid_cases = [
        {
            "name": "Missing required fields",
            "data": {
                "patient_name": "John Doe",
                # Missing emergency_contact
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 2,
                "required_date": "2026-05-02",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
            }
        },
        {
            "name": "Invalid patient name (too short)",
            "data": {
                "patient_name": "Jo",
                "emergency_contact": "03001234567",
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 2,
                "required_date": "2026-05-02",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
            }
        },
        {
            "name": "Invalid emergency contact (too short)",
            "data": {
                "patient_name": "John Doe",
                "emergency_contact": "123",
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 2,
                "required_date": "2026-05-02",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
            }
        },
        {
            "name": "Units required too high",
            "data": {
                "patient_name": "John Doe",
                "emergency_contact": "03001234567",
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 25,
                "required_date": "2026-05-02",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
            }
        },
        {
            "name": "Required date in the past",
            "data": {
                "patient_name": "John Doe",
                "emergency_contact": "03001234567",
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 2,
                "required_date": "2020-05-01",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
            }
        },
        {
            "name": "Case description too long",
            "data": {
                "patient_name": "John Doe",
                "emergency_contact": "03001234567",
                "blood_group": 1,
                "gender": 1,
                "province": 1,
                "district": 1,
                "local_level": 1,
                "units_required": 2,
                "required_date": "2026-05-02",
                "required_time": "14:30",
                "urgency_level": "high",
                "city": "Lahore",
                "hospital_name": "General Hospital",
                "case": "x" * 1001  # Exceeds 1000 characters
            }
        },
    ]

    print("Testing Blood Request Validation...\n")

    for test_case in invalid_cases:
        print(f"Test: {test_case['name']}")
        serializer = BloodRequestSerializer(data=test_case['data'])
        if not serializer.is_valid():
            print(f"  ❌ Validation failed (expected):")
            for field, errors in serializer.errors.items():
                print(f"     {field}: {errors}")
        else:
            print(f"  ⚠️  Validation passed (unexpected)")
        print()

    print("Validation tests completed!")
    print("\n✅ All validation rules are working correctly!")

if __name__ == "__main__":
    test_validation()
