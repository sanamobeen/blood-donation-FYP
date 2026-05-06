# accounts/serializers.py
import re
import logging
from datetime import datetime, date
from typing import Dict, Any
from rest_framework import serializers
from django.core.validators import ValidationError
from .models import MyUser, Donor, GENDERS, PROVINCES, DISTRICTS, BLOOD_GROUPS
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
            "gender",
            "province",
            "district",
            "local_level",
            "date_of_birth",
            "blood_group",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]


# UPDATE PROFILE SERIALIZER
class UpdateProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for updating user profile information.
    All fields are optional to allow partial updates.
    """
    gender = serializers.ChoiceField(
        choices=GENDERS,
        required=False,
        allow_null=True,
        help_text="User's gender"
    )
    province = serializers.ChoiceField(
        choices=PROVINCES,
        required=False,
        allow_null=True,
        help_text="User's province"
    )
    district = serializers.ChoiceField(
        choices=DISTRICTS,
        required=False,
        allow_null=True,
        help_text="User's district"
    )
    blood_group = serializers.ChoiceField(
        choices=BLOOD_GROUPS,
        required=False,
        allow_null=True,
        help_text="User's blood group"
    )
    phone = serializers.CharField(
        required=False,
        allow_null=True,
        allow_blank=True,
        help_text="Contact phone number"
    )
    local_level = serializers.CharField(
        required=False,
        allow_null=True,
        allow_blank=True,
        help_text="Specific area or locality"
    )
    date_of_birth = serializers.DateField(
        required=False,
        allow_null=True,
        help_text="User's date of birth for age validation"
    )

    class Meta:
        model = MyUser
        fields = [
            "full_name",
            "phone",
            "gender",
            "province",
            "district",
            "local_level",
            "date_of_birth",
            "blood_group",
        ]

    def validate_phone(self, value):
        """Validate phone number format if provided"""
        if value:
            phone = value.strip()
            phone_cleaned = re.sub(r"[\s\-\(\)]", "", phone)
            if not re.match(r"^\+?\d{6,15}$", phone_cleaned):
                raise serializers.ValidationError(
                    "Invalid phone number format. Use international format: +92XXXXXXXXXX"
                )
            return phone_cleaned
        return value

    def validate_date_of_birth(self, value):
        """Validate date of birth if provided"""
        if value and self.instance.blood_group:
            today = date.today()
            age = (
                today.year
                - value.year
                - ((today.month, today.day) < (value.month, value.day))
            )
            if age < 18:
                raise serializers.ValidationError(
                    "Donors must be at least 18 years old for safety reasons"
                )
            if age > 65:
                raise serializers.ValidationError(
                    "Donors must be 65 years or younger for safety reasons"
                )
        return value


# REGISTER SERIALIZER
class RegisterSerializer(serializers.ModelSerializer):
    blood_group = serializers.ChoiceField(
        choices=BLOOD_GROUPS,
        write_only=True,
        required=False,
        help_text="User's blood group"
    )
    gender = serializers.ChoiceField(
        choices=GENDERS,
        write_only=True,
        required=False,
        help_text="User's gender"
    )
    province = serializers.ChoiceField(
        choices=PROVINCES,
        write_only=True,
        required=False,
        help_text="User's province"
    )
    district = serializers.ChoiceField(
        choices=DISTRICTS,
        write_only=True,
        required=False,
        help_text="User's district"
    )
    local_level = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        allow_null=True,
        help_text="Specific area or locality"
    )
    date_of_birth = serializers.DateField(
        write_only=True,
        required=False,
        allow_null=True,
        help_text="User's date of birth for age validation"
    )
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password, validate_password_strength],
        help_text="User's password (min 8 chars, must contain uppercase, lowercase, number, special char)"
    )
    confirm_password = serializers.CharField(
        write_only=True,
        required=True,
        help_text="Confirm password"
    )

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
            "blood_group",
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
        if "phone" in attrs and attrs["phone"]:
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
            if attrs.get("blood_group"):
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

        return attrs

    def create(self, validated_data: Dict[str, Any]) -> MyUser:
        """
        Create a new user account with proper validation and error handling.
        Creates both MyUser and Donor records if blood_group is provided.
        """
        from django.db import transaction

        confirm_password = validated_data.pop(
            "confirm_password"
        )  # Remove confirm_password before creating user

        # Extract password before creating user object
        password = validated_data.pop("password")
        blood_group = validated_data.pop("blood_group", None)  # Extract blood_group

        try:
            with transaction.atomic():
                # Add blood_group to user data if provided
                if blood_group:
                    validated_data["blood_group"] = blood_group

                # Create user without password first (active by default, email verification optional)
                user = MyUser(**validated_data)
                user.set_password(password)  # Hash and set the password
                user.full_clean()  # Validate model constraints
                user.save()

                # Create donor profile if blood_group is provided
                if blood_group:
                    Donor.objects.create(
                        user_id=user.id, is_available=True
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
    """
    Serializer for donor profile information.
    Blood group is retrieved from the related MyUser model.
    """
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_full_name = serializers.CharField(source="user.full_name", read_only=True)
    blood_group = serializers.CharField(source="user.blood_group", read_only=True)
    gender = serializers.CharField(source="user.gender", read_only=True)
    province = serializers.CharField(source="user.province", read_only=True)
    district = serializers.CharField(source="user.district", read_only=True)

    class Meta:
        model = Donor
        fields = [
            "id",
            "user_id",
            "user_email",
            "user_full_name",
            "blood_group",
            "gender",
            "province",
            "district",
            "is_available",
            "last_donation_date",
            "total_donations",
            "created_at",
        ]
        read_only_fields = ["id", "created_at", "total_donations", "user_id"]


# DONOR REGISTRATION SERIALIZER
class DonorRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for registering an existing user as a donor.
    Creates a donor profile for the authenticated user.
    """
    blood_group = serializers.ChoiceField(
        choices=BLOOD_GROUPS,
        required=True,
        help_text="Blood group is required to register as a donor"
    )

    class Meta:
        model = Donor
        fields = ["blood_group", "is_available"]

    def create(self, validated_data):
        user = self.context["request"].user
        if Donor.objects.filter(user_id=user.id).exists():
            raise serializers.ValidationError("User is already registered as a donor")

        # Extract blood_group and save it to user model
        blood_group = validated_data.pop("blood_group", None)
        is_available = validated_data.get("is_available", True)

        # Update user with blood group
        if blood_group:
            user.blood_group = blood_group
            user.save()

        # Create donor profile
        validated_data["user_id"] = user.id
        validated_data["is_available"] = is_available
        return super().create(validated_data)


# FORGOT PASSWORD SERIALIZER
class ForgotPasswordSerializer(serializers.Serializer):
    """
    Serializer for forgot password requests.
    Validates email and initiates password reset process.
    """
    email = serializers.EmailField(required=True, help_text="User's email address")

    def validate_email(self, value):
        """
        Validate that email exists in the system.
        Only allow password reset for registered emails.
        """
        email = value.strip().lower()
        if not MyUser.objects.filter(email=email).exists():
            logger.warning(f"Password reset requested for non-existent email: {email}")
            raise serializers.ValidationError(
                "No account found with this email address. Please check your email or register a new account."
            )
        return email


# RESET PASSWORD SERIALIZER
class ResetPasswordSerializer(serializers.Serializer):
    """
    Serializer for resetting password with token.
    Validates token and new password.
    """
    email = serializers.EmailField(required=True, help_text="User's email address")
    token = serializers.UUIDField(required=True, help_text="Password reset token")
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        validators=[validate_password, validate_password_strength],
        help_text="New password",
    )
    confirm_password = serializers.CharField(
        required=True, write_only=True, help_text="Confirm new password"
    )

    def validate(self, attrs):
        """
        Validate token, password confirmation, and user email.
        """
        # Validate password confirmation
        if attrs["new_password"] != attrs["confirm_password"]:
            raise serializers.ValidationError(
                {
                    "new_password": "Password fields didn't match.",
                    "confirm_password": "Passwords must be identical",
                }
            )

        # Validate email exists
        email = attrs["email"].strip().lower()
        try:
            user = MyUser.objects.get(email=email)
            attrs["user"] = user
        except MyUser.DoesNotExist:
            raise serializers.ValidationError(
                {"email": "No user found with this email address"}
            )

        # Validate token
        from .models import PasswordReset

        try:
            reset = PasswordReset.objects.get(token=attrs["token"], user_id=user.id)
            if not reset.is_valid():
                raise serializers.ValidationError(
                    {"token": "Token has expired or already used. Please request a new one."}
                )
            attrs["reset"] = reset
        except PasswordReset.DoesNotExist:
            raise serializers.ValidationError(
                {"token": "Invalid token. Please request a new password reset."}
            )

        return attrs
