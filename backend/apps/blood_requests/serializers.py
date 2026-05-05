from rest_framework import serializers
from datetime import datetime, time, date
from .models import BloodRequest, BLOOD_GROUP_CHOICES, GENDER_CHOICES, PROVINCE_CHOICES

# For frontend compatibility - keep string choices for reference
BLOOD_GROUPS = [
    ("A+", "A+"),
    ("A-", "A-"),
    ("B+", "B+"),
    ("B-", "B-"),
    ("AB+", "AB+"),
    ("AB-", "AB-"),
    ("O+", "O+"),
    ("O-", "O-"),
]

GENDERS = [
    ("Male", "Male"),
    ("Female", "Female"),
    ("Other", "Other"),
]


class BloodRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user_id",
            "patient_name",
            "emergency_contact",
            "blood_group",
            "gender",
            "province",
            "district",
            "local_level",
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "user_id", "status", "created_at", "updated_at"]
        extra_kwargs = {
            "patient_name": {"required": True, "allow_blank": False},
            "emergency_contact": {"required": True, "allow_blank": False},
            "blood_group": {"required": True},
            "gender": {"required": True},
            "units_required": {"required": True, "min_value": 1},
        }

    def validate_patient_name(self, value):
        """Validate patient name"""
        if not value or not value.strip():
            raise serializers.ValidationError("Patient name cannot be empty")
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Patient name must be at least 3 characters long")
        if len(value) > 100:
            raise serializers.ValidationError("Patient name cannot exceed 100 characters")
        return value.strip()

    def validate_emergency_contact(self, value):
        """Validate emergency contact number"""
        if not value or not value.strip():
            raise serializers.ValidationError("Emergency contact cannot be empty")
        value = value.strip()
        clean_number = value.replace("-", "").replace(" ", "").replace("(", "").replace(")", "")
        if len(clean_number) < 10 or len(clean_number) > 15:
            raise serializers.ValidationError("Emergency contact must be between 10-15 digits")
        if not clean_number.isdigit():
            raise serializers.ValidationError("Emergency contact must contain only digits")
        return value

    def validate_units_required(self, value):
        """Validate units required"""
        if value <= 0:
            raise serializers.ValidationError("Units required must be greater than 0")
        if value > 20:
            raise serializers.ValidationError("Units required cannot exceed 20")
        return value

    def validate_required_date(self, value):
        """Validate required date"""
        if not value:
            raise serializers.ValidationError("Required date is required")
        today = date.today()
        if value < today:
            raise serializers.ValidationError("Required date cannot be in the past")
        max_date = date(today.year + 1, today.month, today.day)
        if value > max_date:
            raise serializers.ValidationError("Required date cannot be more than 1 year in the future")
        return value

    def validate_required_time(self, value):
        """Validate required time"""
        if not value:
            raise serializers.ValidationError("Required time is required")
        return value

    def validate_case(self, value):
        """Validate case description"""
        if value:
            value = value.strip()
            if len(value) > 500:
                raise serializers.ValidationError("Case description cannot exceed 500 characters")
            return value
        return value

    def create(self, validated_data):
        validated_data["user_id"] = self.context["request"].user.id
        return super().create(validated_data)


class BloodRequestListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing requests"""
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "patient_name",
            "blood_group",
            "gender",
            "province",
            "district",
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "status_display",
            "created_at",
        ]
