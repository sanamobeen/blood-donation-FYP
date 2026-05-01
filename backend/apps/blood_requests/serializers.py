from rest_framework import serializers
from datetime import datetime, time, date
from .models import BloodRequest
from apps.accounts.models import URGENCY_LEVELS, Province, District, LocalLevel, Gender, BloodGroup


class BloodGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = BloodGroup
        fields = ["id", "name"]


class GenderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gender
        fields = ["id", "name"]


class ProvinceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Province
        fields = ["id", "name", "code"]


class DistrictSerializer(serializers.ModelSerializer):
    province_name = serializers.CharField(source="province.name", read_only=True)

    class Meta:
        model = District
        fields = ["id", "name", "province", "province_name"]


class LocalLevelSerializer(serializers.ModelSerializer):
    district_name = serializers.CharField(source="district.name", read_only=True)

    class Meta:
        model = LocalLevel
        fields = ["id", "name", "district", "district_name"]


class BloodRequestSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_name = serializers.CharField(source="user.get_full_name", read_only=True)
    blood_group_name = serializers.CharField(source="blood_group.name", read_only=True)
    gender_name = serializers.CharField(source="gender.name", read_only=True)
    province_name = serializers.CharField(source="province.name", read_only=True)
    district_name = serializers.CharField(source="district.name", read_only=True)
    local_level_name = serializers.CharField(source="local_level.name", read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user",
            "user_email",
            "user_name",
            "patient_name",
            "emergency_contact",
            "blood_group",
            "blood_group_name",
            "gender",
            "gender_name",
            "province",
            "province_name",
            "district",
            "district_name",
            "local_level",
            "local_level_name",
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "user", "status", "created_at", "updated_at"]
        extra_kwargs = {
            "patient_name": {"required": True, "allow_blank": False},
            "emergency_contact": {"required": True, "allow_blank": False},
            "blood_group": {"required": True},
            "gender": {"required": True},
            "province": {"required": True},
            "district": {"required": True},
            "local_level": {"required": True},
            "units_required": {"required": True, "min_value": 1},
            "required_date": {"required": True},
            "required_time": {"required": True},
        }

    def validate_patient_name(self, value):
        """Validate patient name"""
        if not value or not value.strip():
            raise serializers.ValidationError("Patient name cannot be empty")
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Patient name must be at least 3 characters long")
        if len(value) > 100:
            raise serializers.ValidationError("Patient name cannot exceed 100 characters")
        # Check for valid characters (letters, spaces, hyphens, apostrophes)
        if not all(char.isalnum() or char.isspace() or char in "-'." for char in value):
            raise serializers.ValidationError("Patient name contains invalid characters")
        return value.strip()

    def validate_emergency_contact(self, value):
        """Validate emergency contact number"""
        if not value or not value.strip():
            raise serializers.ValidationError("Emergency contact cannot be empty")
        value = value.strip()
        # Remove common formatting characters
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
            raise serializers.ValidationError("Units required cannot exceed 20 (contact hospital directly for larger requests)")
        return value

    def validate_required_date(self, value):
        """Validate required date"""
        if not value:
            raise serializers.ValidationError("Required date is required")
        today = date.today()
        if value < today:
            raise serializers.ValidationError("Required date cannot be in the past")
        # Check if date is too far in future (more than 1 year)
        max_date = date(today.year + 1, today.month, today.day)
        if value > max_date:
            raise serializers.ValidationError("Required date cannot be more than 1 year in the future")
        return value

    def validate_required_time(self, value):
        """Validate required time"""
        if not value:
            raise serializers.ValidationError("Required time is required")
        if isinstance(value, str):
            try:
                # Parse time string (HH:MM format)
                hour, minute = map(int, value.split(':'))
                if not (0 <= hour <= 23 and 0 <= minute <= 59):
                    raise serializers.ValidationError("Invalid time format")
            except (ValueError, AttributeError):
                raise serializers.ValidationError("Time must be in HH:MM format (24-hour)")
        return value

    def validate_case(self, value):
        """Validate case description"""
        if value:
            value = value.strip()
            if len(value) > 500:
                raise serializers.ValidationError("Case description cannot exceed 500 characters")
            return value
        return value

    def validate(self, attrs):
        """Object-level validation for cross-field validation"""
        # Validate location hierarchy consistency
        province = attrs.get('province')
        district = attrs.get('district')
        local_level = attrs.get('local_level')

        if district and province:
            # Check if district belongs to the specified province
            if district.province != province:
                raise serializers.ValidationError({
                    "district": "Selected district does not belong to the selected province"
                })

        if local_level and district:
            # Check if local_level belongs to the specified district
            if local_level.district != district:
                raise serializers.ValidationError({
                    "local_level": "Selected local level does not belong to the selected district"
                })

        return attrs

    def create(self, validated_data):
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)


class BloodRequestListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing requests"""

    user_name = serializers.CharField(source="user.get_full_name", read_only=True)
    blood_group_name = serializers.CharField(source="blood_group.name", read_only=True)
    gender_name = serializers.CharField(source="gender.name", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    province_name = serializers.CharField(source="province.name", read_only=True)
    district_name = serializers.CharField(source="district.name", read_only=True)
    local_level_name = serializers.CharField(source="local_level.name", read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user_name",
            "patient_name",
            "blood_group",
            "blood_group_name",
            "gender",
            "gender_name",
            "province",
            "province_name",
            "district",
            "district_name",
            "local_level",
            "local_level_name",
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "status_display",
            "created_at",
        ]
