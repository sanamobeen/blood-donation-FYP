# accounts/serializers.py
import re
import logging
from datetime import datetime, date
from typing import Dict, Any
from rest_framework import serializers
from django.core.validators import ValidationError
from .models import MyUser, Donor
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.hashers import make_password

logger = logging.getLogger(__name__)


def validate_password_strength(password: str) -> str:
    """
    Custom password strength validator following security best practices.
    Ensures password meets complexity requirements for enterprise security.
    """
    if len(password) < 8:
        raise serializers.ValidationError("Password must be at least 8 characters long")

    if len(password) > 128:
        raise serializers.ValidationError("Password must not exceed 128 characters")

    if not re.search(r"[A-Z]", password):
        raise serializers.ValidationError(
            "Password must contain at least one uppercase letter"
        )

    if not re.search(r"[a-z]", password):
        raise serializers.ValidationError(
            "Password must contain at least one lowercase letter"
        )

    if not re.search(r"\d", password):
        raise serializers.ValidationError("Password must contain at least one number")

    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        raise serializers.ValidationError(
            "Password must contain at least one special character"
        )

    # Check for common patterns
    common_patterns = ["password", "123456", "qwerty", "admin", "welcome"]
    password_lower = password.lower()
    if any(pattern in password_lower for pattern in common_patterns):
        raise serializers.ValidationError(
            "Password contains common patterns and is not secure enough"
        )

    return password


# USER SERIALIZER
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyUser
        fields = [
            "id",
            "full_name",
            "email",
            "phone",
            "province",
            "district",
            "local_level",
            "gender",
            "date_of_birth",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]


# REGISTER SERIALIZER
class RegisterSerializer(serializers.ModelSerializer):
    # Frontend sends these fields directly
    blood_group = serializers.CharField(write_only=True, required=False)
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password, validate_password_strength],
    )
    confirm_password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = MyUser
        fields = [
            "full_name",
            "email",
            "phone",
            "gender",
            "province",
            "district",
            "local_level",
            "date_of_birth",
            "blood_group",  # Will be used to create donor profile
            "password",
            "confirm_password",
        ]

    def validate(self, attrs: Dict[str, Any]) -> Dict[str, Any]:
        """
        Comprehensive validation for user registration.
        Validates password confirmation, email uniqueness, phone format, and business logic.
        """
        # Validate password confirmation
        if attrs["password"] != attrs["confirm_password"]:
            logger.warning(
                f"Password mismatch attempt for email: {attrs.get('email', 'unknown')}"
            )
            raise serializers.ValidationError(
                {
                    "password": "Password fields didn't match.",
                    "confirm_password": "Passwords must be identical",
                }
            )

        # Validate province is not empty and is a valid choice
        if "province" in attrs:
            if not attrs["province"].strip():
                raise serializers.ValidationError(
                    {"province": "Province cannot be empty"}
                )
            # Safely get province choices with fallback
            province_field = MyUser._meta.get_field("province")
            valid_provinces = [choice[0] for choice in province_field.choices] if province_field.choices else []
            if attrs["province"] not in valid_provinces:
                raise serializers.ValidationError(
                    {"province": "Invalid province selection"}
                )

        # Validate district if provided
        if "district" in attrs and attrs["district"].strip():
            valid_districts = [
                choice[0] for choice in MyUser._meta.get_field("district").choices
            ]
            if attrs["district"] not in valid_districts:
                raise serializers.ValidationError(
                    {"district": "Invalid district selection"}
                )

        # Validate gender is not empty and is valid
        if "gender" in attrs:
            if not attrs["gender"].strip():
                raise serializers.ValidationError({"gender": "Gender cannot be empty"})
            valid_genders = [
                choice[0] for choice in MyUser._meta.get_field("gender").choices
            ]
            if attrs["gender"] not in valid_genders:
                raise serializers.ValidationError(
                    {"gender": "Invalid gender selection"}
                )

        # Validate email format and uniqueness
        if "email" in attrs:
            email = attrs["email"].strip().lower()
            # Basic email format validation
            if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", email):
                raise serializers.ValidationError({"email": "Invalid email format"})

            # Check for email uniqueness
            if MyUser.objects.filter(email=email).exists():
                logger.warning(f"Registration attempt with existing email: {email}")
                raise serializers.ValidationError(
                    {"email": "A user with this email already exists"}
                )
            attrs["email"] = email

        # Validate phone number format (international format support)
        if "phone" in attrs:
            phone = attrs["phone"].strip()
            # Remove spaces, dashes, parentheses for validation
            phone_cleaned = re.sub(r"[\s\-\(\)]", "", phone)
            # Validate phone number format (6-15 digits, optional + prefix)
            if not re.match(r"^\+?\d{6,15}$", phone_cleaned):
                raise serializers.ValidationError(
                    {
                        "phone": "Invalid phone number format. Use international format: +92XXXXXXXXXX"
                    }
                )
            attrs["phone"] = phone_cleaned

        # Validate date of birth for donors (age restrictions)
        if "date_of_birth" in attrs and attrs["date_of_birth"]:
            today = date.today()
            age = (
                today.year
                - attrs["date_of_birth"].year
                - (
                    (today.month, today.day)
                    < (attrs["date_of_birth"].month, attrs["date_of_birth"].day)
                )
            )

            # Donors must be between 18 and 65 years old
            if attrs.get("blood_group") or attrs.get("role") == "donor":
                if age < 18:
                    raise serializers.ValidationError(
                        {
                            "date_of_birth": "Donors must be at least 18 years old for safety reasons"
                        }
                    )
                if age > 65:
                    raise serializers.ValidationError(
                        {
                            "date_of_birth": "Donors must be 65 years or younger for safety reasons"
                        }
                    )

        # Validate blood_group if provided
        if "blood_group" in attrs and attrs["blood_group"]:
            valid_blood_groups = [
                choice[0] for choice in Donor._meta.get_field("blood_group").choices
            ]
            if attrs["blood_group"] not in valid_blood_groups:
                raise serializers.ValidationError(
                    {"blood_group": "Invalid blood group"}
                )

        return attrs

    def create(self, validated_data: Dict[str, Any]) -> MyUser:
        """
        Create a new user account with proper validation and error handling.
        Creates both MyUser and Donor records if blood_group is provided.
        """
        from django.db import transaction

        blood_group = validated_data.pop("blood_group", None)
        confirm_password = validated_data.pop(
            "confirm_password"
        )  # Remove confirm_password before creating user

        # Extract password before creating user object
        password = validated_data.pop("password")

        try:
            with transaction.atomic():
                # Create user without password first (active by default, email verification optional)
                user = MyUser(**validated_data)
                user.set_password(password)  # Hash and set the password
                user.full_clean()  # Validate model constraints
                user.save()

                # Create donor profile if blood_group is provided
                if blood_group:
                    Donor.objects.create(
                        user=user, blood_group=blood_group, is_available=True
                    )
                    logger.info(f"Created new donor account: {user.email}")

                return user

        except ValidationError as e:
            logger.error(f"Validation error during user creation: {e.message_dict}")
            raise serializers.ValidationError(e.message_dict)
        except Exception as e:
            logger.error(f"Error during user creation: {str(e)}")
            raise serializers.ValidationError(
                {"detail": "An error occurred during registration. Please try again."}
            )


# LOGIN SERIALIZER
class LoginSerializer(serializers.Serializer):
    """
    Serializer for user login authentication.
    Validates credentials and returns authenticated user.
    """

    email = serializers.EmailField(required=True, help_text="User's email address")
    password = serializers.CharField(
        required=True,
        write_only=True,
        style={"input_type": "password"},
        help_text="User's password",
    )

    def validate(self, attrs: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validate login credentials and authenticate user.
        Provides generic error messages for security.
        """
        email = attrs.get("email")
        password = attrs.get("password")

        if not email or not password:
            raise serializers.ValidationError("Must include email and password")

        # Normalize email
        email = email.strip().lower()

        # Authenticate user
        user = authenticate(username=email, password=password)

        if not user:
            # Log failed login attempt
            logger.warning(f"Failed login attempt for email: {email}")
            raise serializers.ValidationError("Invalid email or password")

        if not user.is_active:
            logger.warning(f"Login attempt for disabled account: {email}")
            raise serializers.ValidationError(
                "This account has been disabled. Please contact support."
            )

        attrs["user"] = user
        logger.info(f"Successful login for: {email}")
        return attrs


# DONOR SERIALIZER
class DonorSerializer(serializers.ModelSerializer):
    # Include user information as individual fields instead of nested object
    email = serializers.EmailField(source="user.email", read_only=True)
    full_name = serializers.CharField(source="user.full_name", read_only=True)
    phone = serializers.CharField(source="user.phone", read_only=True)
    province = serializers.CharField(source="user.province", read_only=True)
    district = serializers.CharField(source="user.district", read_only=True)
    local_level = serializers.CharField(source="user.local_level", read_only=True)
    gender = serializers.CharField(source="user.gender", read_only=True)
    date_of_birth = serializers.DateField(source="user.date_of_birth", read_only=True)

    class Meta:
        model = Donor
        fields = [
            "id",
            "email",
            "full_name",
            "phone",
            "province",
            "district",
            "local_level",
            "gender",
            "date_of_birth",
            "blood_group",
            "is_available",
            "last_donation_date",
            "total_donations",
            "created_at",
        ]
        read_only_fields = ["id", "created_at", "total_donations"]


# DONOR REGISTRATION SERIALIZER
class DonorRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Donor
        fields = ["blood_group", "is_available"]

    def create(self, validated_data):
        user = self.context["request"].user
        if Donor.objects.filter(user=user).exists():
            raise serializers.ValidationError("User is already registered as a donor")
        validated_data["user"] = user
        return super().create(validated_data)
