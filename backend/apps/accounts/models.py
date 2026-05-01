from django.db import models
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)
from django.utils import timezone
import uuid

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
]

DISTRICTS = [
    # Punjab Districts
    ("Lahore", "Lahore"),
    ("Faisalabad", "Faisalabad"),
    ("Rawalpindi", "Rawalpindi"),
    ("Multan", "Multan"),
    ("Gujranwala", "Gujranwala"),
    ("Sialkot", "Sialkot"),
    ("Sargodha", "Sargodha"),
    ("Bahawalpur", "Bahawalpur"),
    ("Dera Ghazi Khan", "Dera Ghazi Khan"),
    ("Sheikhupura", "Sheikhupura"),
    # Sindh Districts
    ("Karachi", "Karachi"),
    ("Hyderabad", "Hyderabad"),
    ("Sukkur", "Sukkur"),
    ("Larkana", "Larkana"),
    ("Mirpurkhas", "Mirpurkhas"),
    ("Nawabshah", "Nawabshah"),
    # KPK Districts
    ("Peshawar", "Peshawar"),
    ("Mardan", "Mardan"),
    ("Swat", "Swat"),
    ("Abbottabad", "Abbottabad"),
    ("Mingora", "Mingora"),
    ("Kohat", "Kohat"),
    ("Dera Ismail Khan", "Dera Ismail Khan"),
    # Balochistan Districts
    ("Quetta", "Quetta"),
    ("Gwadar", "Gwadar"),
    ("Turbat", "Turbat"),
    ("Sibi", "Sibi"),
    ("Loralai", "Loralai"),
    # Islamabad Districts
    ("Islamabad", "Islamabad"),
    # Gilgit-Baltistan Districts
    ("Gilgit", "Gilgit"),
    ("Skardu", "Skardu"),
    ("Hunza", "Hunza"),
    # Azad Kashmir Districts
    ("Muzaffarabad", "Muzaffarabad"),
    ("Mirpur", "Mirpur"),
    ("Rawalakot", "Rawalakot"),
    ("Khushab", "Khushab"),
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

URGENCY_LEVELS = [
    ("low", "Low"),
    ("medium", "Medium"),
    ("high", "High - Critical"),
]

REQUEST_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("partially_fulfilled", "Partially Fulfilled"),
    ("completed", "Completed"),
    ("cancelled", "Cancelled"),
]

DONATION_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
]


# Location Models
class BloodGroup(models.Model):
    """
    BloodGroup model for standardizing blood group options across the system.
    """
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=3, unique=True)

    class Meta:
        verbose_name = "Blood Group"
        verbose_name_plural = "Blood Groups"
        ordering = ["name"]

    def __str__(self):
        return self.name


class Gender(models.Model):
    """
    Gender model for standardizing gender options across the system.
    """
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=10, unique=True)

    class Meta:
        verbose_name = "Gender"
        verbose_name_plural = "Genders"
        ordering = ["name"]

    def __str__(self):
        return self.name


class Province(models.Model):
    """
    Province model for hierarchical location data.
    """
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100, unique=True)
    code = models.CharField(max_length=10, unique=True)

    class Meta:
        verbose_name = "Province"
        verbose_name_plural = "Provinces"
        ordering = ["name"]

    def __str__(self):
        return self.name


class District(models.Model):
    """
    District model belonging to a province.
    """
    id = models.AutoField(primary_key=True)
    province = models.ForeignKey(
        Province,
        on_delete=models.CASCADE,
        related_name="districts"
    )
    name = models.CharField(max_length=100)

    class Meta:
        verbose_name = "District"
        verbose_name_plural = "Districts"
        ordering = ["name"]
        unique_together = ["province", "name"]

    def __str__(self):
        return f"{self.name}, {self.province.name}"


class LocalLevel(models.Model):
    """
    Local level (town/city/area) model belonging to a district.
    """
    id = models.AutoField(primary_key=True)
    district = models.ForeignKey(
        District,
        on_delete=models.CASCADE,
        related_name="local_levels"
    )
    name = models.CharField(max_length=200)

    class Meta:
        verbose_name = "Local Level"
        verbose_name_plural = "Local Levels"
        ordering = ["name"]
        unique_together = ["district", "name"]

    def __str__(self):
        return f"{self.name}, {self.district.name}"


# Manager
class MyUserManager(BaseUserManager):

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")

        email = self.normalize_email(email)
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        extra_fields.setdefault("is_active", True)

        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("full_name", "Superuser")
        extra_fields.setdefault("phone", "")
        extra_fields.setdefault("gender", "Other")
        # province will be set to None by default
        return self.create_user(email, password, **extra_fields)


# User Model
class MyUser(AbstractBaseUser, PermissionsMixin):
    """
    Custom User model for blood donation system.
    Uses email as the username field and includes location-based fields for donor matching.
    """

    id = models.AutoField(primary_key=True)
    full_name = models.CharField(
        max_length=100,
        blank=True,
        default="",
        verbose_name="Full Name",
        help_text="User's complete name"
    )
    email = models.EmailField(
        unique=True,
        verbose_name="Email Address",
        help_text="Unique email address for login",
    )
    password = models.CharField(
        max_length=128, verbose_name="Password", help_text="Hashed password"
    )
    phone = models.CharField(
        max_length=15,
        blank=True,
        default="",
        verbose_name="Phone Number",
        help_text="Contact phone number"
    )
    province = models.ForeignKey(
        Province,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="Province",
        help_text="User's province"
    )
    district = models.ForeignKey(
        District,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="District",
        help_text="User's district within province",
    )
    local_level = models.ForeignKey(
        LocalLevel,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="Local Level",
        help_text="Specific area or locality",
    )
    gender = models.ForeignKey(
        Gender,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        verbose_name="Gender",
        help_text="User's gender",
        related_name="users",
    )
    date_of_birth = models.DateField(
        blank=True,
        null=True,
        verbose_name="Date of Birth",
        help_text="User's date of birth for age validation",
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Created At",
        help_text="Account creation timestamp",
    )
    updated_at = models.DateTimeField(
        auto_now=True, verbose_name="Updated At", help_text="Last update timestamp"
    )

    is_staff = models.BooleanField(
        default=False,
        verbose_name="Staff Status",
        help_text="Designates whether the user can log into this admin site",
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name="Active",
        help_text="Designates whether this user should be treated as active",
    )

    objects = MyUserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["email"]),
            models.Index(fields=["province", "district"]),
            models.Index(fields=["created_at"]),
        ]

    def get_full_name(self) -> str:
        """Return the user's full name."""
        return self.full_name.strip()

    def get_gender_display(self) -> str:
        """Get the human-readable gender name."""
        return dict(self._meta.get_field("gender").choices).get(
            self.gender, self.gender
        )

    def __str__(self) -> str:
        return self.email


# Donor Model
class Donor(models.Model):
    """
    Donor profile extending User model with blood donation specific information.
    One-to-one relationship with MyUser model.
    """

    id = models.AutoField(primary_key=True)
    user = models.OneToOneField(
        MyUser,
        on_delete=models.CASCADE,
        related_name="donor_profile",
        verbose_name="User",
        help_text="Reference to the user account",
    )
    blood_group = models.CharField(
        max_length=3,
        choices=BLOOD_GROUPS,
        verbose_name="Blood Group",
        help_text="Donor's blood type",
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
            models.Index(fields=["blood_group"]),
            models.Index(fields=["is_available"]),
            models.Index(fields=["user"]),
        ]

    def __str__(self) -> str:
        return f"{self.user.email} - {self.blood_group}"

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
        MyUser,
        on_delete=models.CASCADE,
        related_name="email_verifications",
        verbose_name="User",
        help_text="Reference to the user account",
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
        default=False, verbose_name="Used", help_text="Whether the token has been used"
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
        MyUser,
        on_delete=models.CASCADE,
        related_name="password_resets",
        verbose_name="User",
        help_text="Reference to the user account",
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
        default=False, verbose_name="Used", help_text="Whether the token has been used"
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
