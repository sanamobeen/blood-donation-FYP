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
    # Display fields for better frontend experience
    blood_group_name = serializers.CharField(read_only=True)
    gender_name = serializers.CharField(read_only=True)
    province_name = serializers.CharField(read_only=True)
    district_name = serializers.CharField(read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    # User information
    user = serializers.SerializerMethodField()
    user_email = serializers.SerializerMethodField()
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user",
            "user_id",
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
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "status_display",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "user_id", "status", "created_at", "updated_at"]
        extra_kwargs = {
            "patient_name": {"required": True, "allow_blank": False},
            "emergency_contact": {"required": True, "allow_blank": False},
            "blood_group": {"required": True},
            "gender": {"required": True},
            "province": {"required": True},
            "district": {"required": True},
            "local_level": {"required": False, "allow_blank": True},
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
        """Validate emergency contact number - supports international format"""
        if not value or not value.strip():
            raise serializers.ValidationError("Emergency contact cannot be empty")
        value = value.strip()
        # Remove common formatting characters for validation
        clean_number = value.replace("-", "").replace(" ", "").replace("(", "").replace(")", "").replace("+", "")
        if len(clean_number) < 10 or len(clean_number) > 15:
            raise serializers.ValidationError("Emergency contact must be between 10-15 digits")
        if not clean_number.isdigit():
            raise serializers.ValidationError("Emergency contact must contain only digits and optional + prefix")
        # Return the original value with proper formatting
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

    def validate(self, attrs):
        """Custom validation for date and time combination"""
        required_date = attrs.get('required_date')
        required_time = attrs.get('required_time')

        if required_date and required_time:
            from datetime import datetime, timedelta

            # Combine date and time
            required_datetime = datetime.combine(required_date, required_time)

            # Get current time with buffer (2 minutes to account for API request time)
            current_time = datetime.now() - timedelta(minutes=2)

            # Check if the datetime is in the past
            if required_datetime < current_time:
                raise serializers.ValidationError({
                    "required_time": "Cannot select past time. Please choose current or future time."
                })

        return attrs

    def validate_case(self, value):
        """Validate case description"""
        if value:
            value = value.strip()
            if len(value) > 500:
                raise serializers.ValidationError("Case description cannot exceed 500 characters")
            return value
        return value

    def validate_blood_group(self, value):
        """Validate blood group is one of the allowed choices"""
        if value not in [choice[0] for choice in BLOOD_GROUP_CHOICES]:
            raise serializers.ValidationError("Invalid blood group. Must be one of: A+, A-, B+, B-, AB+, AB-, O+, O-")
        return value

    def validate_gender(self, value):
        """Validate gender is one of the allowed choices"""
        if value not in [choice[0] for choice in GENDER_CHOICES]:
            raise serializers.ValidationError("Invalid gender. Must be one of: Male, Female, Other")
        return value

    def validate_province(self, value):
        """Validate province is one of the allowed choices"""
        if value not in [choice[0] for choice in PROVINCE_CHOICES]:
            raise serializers.ValidationError("Invalid province. Must be one of the Pakistani provinces")
        return value

    def validate_district(self, value):
        """Validate district is one of the allowed choices"""
        from .models import DISTRICT_CHOICES
        if value not in [choice[0] for choice in DISTRICT_CHOICES]:
            raise serializers.ValidationError("Invalid district. Must be one of the Pakistani districts")
        return value

    def validate_local_level(self, value):
        """Validate local level - optional field"""
        if value:
            value = value.strip()
            if len(value) > 200:
                raise serializers.ValidationError("Local level cannot exceed 200 characters")
            return value
        return value

    def get_user(self, obj):
        """Get user ID"""
        return obj.user_id

    def get_user_email(self, obj):
        """Get user email from related user"""
        try:
            from apps.accounts.models import MyUser
            user = MyUser.objects.get(id=obj.user_id)
            return user.email
        except MyUser.DoesNotExist:
            return None

    def get_user_name(self, obj):
        """Get user name from related user"""
        try:
            from apps.accounts.models import MyUser
            user = MyUser.objects.get(id=obj.user_id)
            return user.full_name or user.email
        except MyUser.DoesNotExist:
            return None

    def create(self, validated_data):
        validated_data["user_id"] = self.context["request"].user.id
        return super().create(validated_data)


class BloodRequestListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing requests"""
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    blood_group_name = serializers.CharField(read_only=True)
    gender_name = serializers.CharField(read_only=True)
    province_name = serializers.CharField(read_only=True)
    district_name = serializers.CharField(read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "patient_name",
            "blood_group",
            "blood_group_name",
            "gender",
            "gender_name",
            "province",
            "province_name",
            "district",
            "district_name",
            "units_required",
            "required_date",
            "required_time",
            "case",
            "status",
            "status_display",
            "created_at",
        ]
