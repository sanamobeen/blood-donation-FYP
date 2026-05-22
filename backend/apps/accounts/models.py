from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
import uuid

# Custom User Manager
class CustomUserManager(BaseUserManager):
    """Custom user manager for email-based authentication"""

    def create_user(self, email, password=None, **extra_fields):
        """Create and save a regular user with the given email and password."""
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """Create and save a superuser with the given email and password."""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)


# Custom User Model
class CustomUser(AbstractBaseUser, PermissionsMixin):
    """
    Custom user model for blood donation system.
    Uses email as the primary identifier instead of username.
    """

    email = models.EmailField(
        unique=True,
        max_length=255,
        verbose_name="Email Address",
        help_text="Primary email address for authentication and contact"
    )
    full_name = models.CharField(
        max_length=150,
        blank=True,
        verbose_name="First Name",
        help_text="User's first name"
    )
    
    phone = models.CharField(
        max_length=15,
        blank=True,
        null=True,
        verbose_name="Phone Number",
        help_text="Contact phone number"
    )
    is_staff = models.BooleanField(
        default=False,
        verbose_name="Staff Status",
        help_text="Designates whether the user can log into this admin site"
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name="Active",
        help_text="Designates whether this user should be treated as active"
    )
    date_joined = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Date Joined",
        help_text="Date and time when the user account was created"
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name="Last Updated",
        help_text="Date and time when the user was last updated"
    )

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []  # No additional required fields besides email/password

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"
        ordering = ['-date_joined']
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['phone']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self) -> str:
        return self.email

    def get_full_name(self) -> str:
        """Return the user's full name."""
        return self.full_name if self.full_name else self.email

    def get_short_name(self) -> str:
        """Return the user's short name."""
        return self.full_name.split()[0] if self.full_name else self.email.split('@')[0]


# Choices
GENDERS = [
    ("Male", "Male"),
    ("Female", "Female"),
    ("Other", "Other"),
]

PROVINCES = [
    ("Punjab", "Punjab"),
    ("Sindh", "Sindh"),
    ("Khyber Pakhtunkhwa", "Khyber Pakhtunkhwa"),
    ("Balochistan", "Balochistan"),
    ("Islamabad Capital Territory", "Islamabad Capital Territory"),
    ("Gilgit-Baltistan", "Gilgit-Baltistan"),
    ("Azad Jammu and Kashmir", "Azad Jammu and Kashmir"),
]

DISTRICTS = [
    # Punjab (major districts only for brevity)
    ("Lahore", "Lahore"),
    ("Faisalabad", "Faisalabad"),
    ("Rawalpindi", "Rawalpindi"),
    ("Multan", "Multan"),
    ("Gujranwala", "Gujranwala"),
    ("Sialkot", "Sialkot"),
    # Sindh (major districts)
    ("Karachi", "Karachi"),
    ("Hyderabad", "Hyderabad"),
    ("Sukkur", "Sukkur"),
    # KPK (major districts)
    ("Peshawar", "Peshawar"),
    ("Mardan", "Mardan"),
    # Balochistan (major districts)
    ("Quetta", "Quetta"),
    # Islamabad
    ("Islamabad", "Islamabad"),
    # Other
    ("Other", "Other"),
]

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

# User Profile Model - Extends Django's default User
class UserProfile(models.Model):
    """
    Extended user profile for blood donation system.
    Links to CustomUser model for additional blood donation specific information.
    """

    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name="blood_profile",
        verbose_name="User"
    )
    phone = models.CharField(
        max_length=15,
        blank=True,
        default="",
        verbose_name="Phone Number",
        help_text="Contact phone number"
    )
    gender = models.CharField(
        max_length=10,
        choices=GENDERS,
        blank=True,
        null=True,
        verbose_name="Gender",
        help_text="User's gender",
    )
    province = models.CharField(
        max_length=100,
        choices=PROVINCES,
        blank=True,
        null=True,
        verbose_name="Province",
        help_text="User's province"
    )
    district = models.CharField(
        max_length=100,
        choices=DISTRICTS,
        blank=True,
        null=True,
        verbose_name="District",
        help_text="User's district within province",
    )
    local_level = models.CharField(
        max_length=200,
        blank=True,
        null=True,
        verbose_name="Local Level",
        help_text="Specific area or locality",
    )
    date_of_birth = models.DateField(
        blank=True,
        null=True,
        verbose_name="Date of Birth",
        help_text="User's date of birth for age validation",
    )
    blood_group = models.CharField(
        max_length=3,
        choices=BLOOD_GROUPS,
        blank=True,
        null=True,
        verbose_name="Blood Group",
        help_text="User's blood group",
    )
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Latitude",
        help_text="GPS latitude coordinate"
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Longitude",
        help_text="GPS longitude coordinate"
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created At",
        help_text="Profile creation timestamp",
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name="Updated At",
        help_text="Last update timestamp"
    )

    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user"]),
            models.Index(fields=["blood_group"]),
            models.Index(fields=["created_at"]),
            models.Index(fields=["latitude", "longitude"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.email} - Profile"

    def get_full_name(self) -> str:
        """Return the user's full name."""
        return f"{self.user.first_name} {self.user.last_name}".strip() or self.user.username


# Donor Model - Uses proper ForeignKey to User
class Donor(models.Model):
    """
    Donor profile with blood donation specific information.
    Properly linked to CustomUser model.
    """

    user = models.OneToOneField(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name="donor_profile",
        verbose_name="User"
    )
    is_available = models.BooleanField(
        default=True,
        verbose_name="Available for Donation",
        help_text="Whether the donor is currently available for blood donation",
    )
    last_donation_date = models.DateField(
        blank=True,
        null=True,
        verbose_name="Last Donation Date",
        help_text="Date of the most recent blood donation",
    )
    total_donations = models.IntegerField(
        default=0,
        verbose_name="Total Donations",
        help_text="Total number of blood donations made",
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created At",
        help_text="Donor profile creation timestamp",
    )

    class Meta:
        verbose_name = "Donor"
        verbose_name_plural = "Donors"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user"]),
            models.Index(fields=["is_available"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.email} - Donor"

    def can_donate(self) -> bool:
        """
        Check if donor is eligible to donate based on last donation date.
        Donors must wait 3 months between donations.
        """
        if not self.last_donation_date:
            return True

        from datetime import datetime, timedelta

        three_months_ago = datetime.now().date() - timedelta(days=90)
        return self.last_donation_date <= three_months_ago


# Email Verification Model
class EmailVerification(models.Model):
    """
    Email verification tokens for user account activation.
    Tokens expire after 24 hours for security.
    """

    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name="email_verifications",
        verbose_name="User"
    )
    token = models.UUIDField(
        default=uuid.uuid4,
        editable=False,
        unique=True,
        verbose_name="Verification Token",
        help_text="Unique token for email verification",
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created At",
        help_text="Token creation timestamp",
    )
    is_used = models.BooleanField(
        default=False,
        verbose_name="Used",
        help_text="Whether the token has been used"
    )

    class Meta:
        verbose_name = "Email Verification"
        verbose_name_plural = "Email Verifications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["token"]),
            models.Index(fields=["user", "is_used"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.email} - {self.token}"

    def is_valid(self) -> bool:
        """
        Check if token is valid (not used and not expired - 24 hours).
        Returns True if token can be used for verification.
        """
        if self.is_used:
            return False
        expiration_time = timezone.now() - timezone.timedelta(hours=24)
        return self.created_at > expiration_time


# Password Reset Model
class PasswordReset(models.Model):
    """
    Password reset tokens for users who forgot their password.
    Tokens expire after 1 hour for security.
    """

    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(
        'accounts.CustomUser',
        on_delete=models.CASCADE,
        related_name="password_resets",
        verbose_name="User"
    )
    token = models.UUIDField(
        default=uuid.uuid4,
        editable=False,
        unique=True,
        verbose_name="Reset Token",
        help_text="Unique token for password reset",
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created At",
        help_text="Token creation timestamp",
    )
    is_used = models.BooleanField(
        default=False,
        verbose_name="Used",
        help_text="Whether the token has been used"
    )

    class Meta:
        verbose_name = "Password Reset"
        verbose_name_plural = "Password Resets"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["token"]),
            models.Index(fields=["user", "is_used"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.email} - {self.token}"

    def is_valid(self) -> bool:
        """
        Check if token is valid (not used and not expired - 1 hour).
        Returns True if token can be used for password reset.
        """
        if self.is_used:
            return False
        expiration_time = timezone.now() - timezone.timedelta(hours=1)
        return self.created_at > expiration_time
