# accounts/serializers.py - Updated for CustomUser model
import re
import logging
from datetime import date
from typing import Dict, Any
from rest_framework import serializers
from django.core.validators import ValidationError
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from .models import CustomUser, UserProfile, Donor, GENDERS, PROVINCES, DISTRICTS, BLOOD_GROUPS

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
        raise serializers.ValidationError(
            "Password must contain at least one number"
        )

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


# USER PROFILE SERIALIZER
class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for user profile information.
    Handles blood donation specific fields.
    """
    email = serializers.EmailField(source="user.email", read_only=True)
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            "id",
            "email",
            "full_name",
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

    def get_full_name(self, obj) -> str:
        """Get full name from associated CustomUser model"""
        return obj.user.get_full_name()


# USER SERIALIZER (CustomUser)
class UserSerializer(serializers.ModelSerializer):
    """
    Serializer for CustomUser model.
    Includes profile information through nested serialization.
    """
    profile = UserProfileSerializer(read_only=True)
    full_name = serializers.SerializerMethodField()
    password = serializers.CharField(write_only=True, required=False)
    confirm_password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = CustomUser
        fields = [
            "id",
            "email",
            "full_name",
            "phone",
            "password",
            "confirm_password",
            "is_staff",
            "is_active",
            "date_joined",
            "profile",
        ]
        read_only_fields = ["id", "is_staff", "is_active", "date_joined"]
        extra_kwargs = {
            'password': {'write_only': True},
            'confirm_password': {'write_only': True}
        }

    def get_full_name(self, obj) -> str:
        """Return the user's full name"""
        return obj.get_full_name()


# UPDATE PROFILE SERIALIZER
class UpdateProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for updating user profile information.
    All fields are optional to allow partial updates.
    """
    class Meta:
        model = UserProfile
        fields = [
            "gender",
            "province",
            "district",
            "local_level",
            "date_of_birth",
            "blood_group",
        ]

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
    """
    Serializer for user registration.
    Creates CustomUser and UserProfile records.
   """
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
        model = CustomUser
        fields = [
            "email",
            "full_name",
            "phone",
            "password",
            "confirm_password",
        ]

    def validate(self, attrs: Dict[str, Any]) -> Dict[str, Any]:
        """Comprehensive validation for user registration"""
        # Validate password confirmation
        if attrs["password"] != attrs["confirm_password"]:
            raise serializers.ValidationError(
                {
                    "password": "Password fields didn't match.",
                    "confirm_password": "Passwords must be identical",
                }
            )

        # Validate email format and uniqueness
        email = attrs.get("email", "").strip().lower()
        if not email:
            raise serializers.ValidationError({"email": "Email is required"})

        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", email):
            raise serializers.ValidationError({"email": "Invalid email format"})

        if CustomUser.objects.filter(email=email).exists():
            raise serializers.ValidationError(
                {"email": "A user with this email already exists"}
            )
        attrs["email"] = email

        # Validate phone number format
        phone = attrs.get("phone", "").strip()
        if phone:
            phone_cleaned = re.sub(r"[\s\-\(\)]", "", phone)
            if not re.match(r"^\+?\d{6,15}$", phone_cleaned):
                raise serializers.ValidationError(
                    {"phone": "Invalid phone number format. Use international format: +92XXXXXXXXXX"}
                )
            attrs["phone"] = phone_cleaned

        return attrs

    def create(self, validated_data: Dict[str, Any]) -> CustomUser:
        """Create a new user account with UserProfile"""
        from django.db import transaction

        validated_data.pop("confirm_password")

        # Extract profile fields (blood donation specific)
        profile_fields = {
            'gender': validated_data.pop('gender', 'Other'),
            'province': validated_data.pop('province', 'Punjab'),
            'district': validated_data.pop('district', 'Lahore'),
            'local_level': validated_data.pop('local_level', 'Urban'),
            'date_of_birth': validated_data.pop('date_of_birth', None),
            'blood_group': validated_data.pop('blood_group', None),
        }

        password = validated_data.pop("password")

        # Clean up empty date_of_birth
        if not profile_fields['date_of_birth']:
            profile_fields.pop('date_of_birth')

        try:
            with transaction.atomic():
                # Create CustomUser with the new structure
                user = CustomUser(
                    email=validated_data.get('email'),
                    full_name=validated_data.get('full_name', ''),
                    phone=validated_data.get('phone', ''),
                )
                user.set_password(password)
                user.full_clean()
                user.save()

                # Create UserProfile with blood donation specific fields
                UserProfile.objects.create(user=user, **profile_fields)

                # Create donor profile if blood_group is provided
                if profile_fields.get('blood_group'):
                    Donor.objects.create(user=user, is_available=True)
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
    """Serializer for user login authentication"""
    email = serializers.EmailField(required=True, help_text="User's email address")
    password = serializers.CharField(
        required=True,
        write_only=True,
        style={"input_type": "password"},
        help_text="User's password",
    )

    def validate(self, attrs: Dict[str, Any]) -> Dict[str, Any]:
        """Validate login credentials and authenticate user"""
        email = attrs.get("email")
        password = attrs.get("password")

        if not email or not password:
            raise serializers.ValidationError("Must include email and password")

        email = email.strip().lower()

        # Authenticate user
        user = authenticate(username=email, password=password)

        if not user:
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
    """Serializer for donor profile information"""
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_full_name = serializers.CharField(source="user.get_full_name", read_only=True)
    blood_group = serializers.CharField(source="user.blood_profile.blood_group", read_only=True)
    gender = serializers.CharField(source="user.blood_profile.gender", read_only=True)
    province = serializers.CharField(source="user.blood_profile.province", read_only=True)
    district = serializers.CharField(source="user.blood_profile.district", read_only=True)

    class Meta:
        model = Donor
        fields = [
            "id",
            "user",
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
        read_only_fields = ["id", "created_at", "total_donations", "user"]
        extra_kwargs = {
            'user': {'required': False}
        }


# DONOR REGISTRATION SERIALIZER
class DonorRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for registering an existing user as a donor"""
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
        if Donor.objects.filter(user=user).exists():
            raise serializers.ValidationError("User is already registered as a donor")

        # Extract blood_group and update user profile
        blood_group = validated_data.pop("blood_group", None)
        is_available = validated_data.get("is_available", True)

        # Update user profile with blood group
        if blood_group:
            profile, created = UserProfile.objects.get_or_create(user=user)
            profile.blood_group = blood_group
            profile.save()

        # Create donor profile
        validated_data["user"] = user
        validated_data["is_available"] = is_available
        return super().create(validated_data)


# FORGOT PASSWORD SERIALIZER
class ForgotPasswordSerializer(serializers.Serializer):
    """Serializer for forgot password requests"""
    email = serializers.EmailField(required=True, help_text="User's email address")

    def validate_email(self, value):
        """Validate that email exists in the system"""
        email = value.strip().lower()
        if not CustomUser.objects.filter(email=email).exists():
            logger.warning(f"Password reset requested for non-existent email: {email}")
            raise serializers.ValidationError(
                "No account found with this email address. Please check your email or register a new account."
            )
        return email


# RESET PASSWORD SERIALIZER
class ResetPasswordSerializer(serializers.Serializer):
    """Serializer for resetting password with token"""
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
        """Validate token, password confirmation, and user email"""
        if attrs["new_password"] != attrs["confirm_password"]:
            raise serializers.ValidationError(
                {
                    "new_password": "Password fields didn't match.",
                    "confirm_password": "Passwords must be identical",
                }
            )

        email = attrs["email"].strip().lower()
        try:
            user = CustomUser.objects.get(email=email)
            attrs["user"] = user
        except User.DoesNotExist:
            raise serializers.ValidationError(
                {"email": "No user found with this email address"}
            )

        # Import here to avoid circular imports
        from .models import PasswordReset

        try:
            reset = PasswordReset.objects.get(token=attrs["token"], user=user)
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
