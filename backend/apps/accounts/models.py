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
        extra_fields.setdefault("province", "Punjab")
        extra_fields.setdefault("gender", "Other")
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
    province = models.CharField(
        max_length=100,
        choices=PROVINCES,
        default="Punjab",
        verbose_name="Province",
        help_text="User's province"
    )
    district = models.CharField(
        max_length=100,
        choices=DISTRICTS,
        blank=True,
        default="",
        verbose_name="District",
        help_text="User's district within province",
    )
    local_level = models.CharField(
        max_length=200,
        blank=True,
        default="",
        verbose_name="Local Level",
        help_text="Specific area or locality",
    )
    gender = models.CharField(
        max_length=6,
        choices=GENDERS,
        default="Other",
        verbose_name="Gender",
        help_text="User's gender",
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

    def get_province_display(self) -> str:
        """Get the human-readable province name."""
        return dict(self._meta.get_field("province").choices).get(
            self.province, self.province
        )

    def get_district_display(self) -> str:
        """Get the human-readable district name."""
        return dict(self._meta.get_field("district").choices).get(
            self.district, self.district
        )

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
