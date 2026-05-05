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
    ("Islamabad Capital Territory", "Islamabad Capital Territory"),
    ("Gilgit-Baltistan", "Gilgit-Baltistan"),
    ("Azad Jammu and Kashmir", "Azad Jammu and Kashmir"),
]

DISTRICTS = [
    # Punjab
    ("Ahmedpur East", "Ahmedpur East"),
    ("Arifwala", "Arifwala"),
    ("Attock", "Attock"),
    ("Bahawalnagar", "Bahawalnagar"),
    ("Bahawalpur", "Bahawalpur"),
    ("Bhakkar", "Bhakkar"),
    ("Burewala", "Burewala"),
    ("Chakwal", "Chakwal"),
    ("Chiniot", "Chiniot"),
    ("Dera Ghazi Khan", "Dera Ghazi Khan"),
    ("Faisalabad", "Faisalabad"),
    ("Ferozewala", "Ferozewala"),
    ("Gujranwala", "Gujranwala"),
    ("Gujrat", "Gujrat"),
    ("Hafizabad", "Hafizabad"),
    ("Jhang", "Jhang"),
    ("Jhelum", "Jhelum"),
    ("Kasur", "Kasur"),
    ("Khanewal", "Khanewal"),
    ("Khushab", "Khushab"),
    ("Lahore", "Lahore"),
    ("Layyah", "Layyah"),
    ("Lodhran", "Lodhran"),
    ("Mandi Bahauddin", "Mandi Bahauddin"),
    ("Mianwali", "Mianwali"),
    ("Multan", "Multan"),
    ("Muzaffargarh", "Muzaffargarh"),
    ("Nankana Sahib", "Nankana Sahib"),
    ("Narowal", "Narowal"),
    ("Okara", "Okara"),
    ("Pakpattan", "Pakpattan"),
    ("Rahim Yar Khan", "Rahim Yar Khan"),
    ("Rajanpur", "Rajanpur"),
    ("Rawalpindi", "Rawalpindi"),
    ("Sahiwal", "Sahiwal"),
    ("Sargodha", "Sargodha"),
    ("Sheikhupura", "Sheikhupura"),
    ("Sialkot", "Sialkot"),
    ("Toba Tek Singh", "Toba Tek Singh"),
    ("Vehari", "Vehari"),
    ("Wazirabad", "Wazirabad"),
    # Sindh
    ("Badin", "Badin"),
    ("Bhan", "Bhan"),
    ("Chachro", "Chachro"),
    ("Dadu", "Dadu"),
    ("Diplo", "Diplo"),
    ("Ghotki", "Ghotki"),
    ("Hyderabad", "Hyderabad"),
    ("Jacobabad", "Jacobabad"),
    ("Jamshoro", "Jamshoro"),
    ("Karachi", "Karachi"),
    ("Kashmore", "Kashmore"),
    ("Kandhkot", "Kandhkot"),
    ("Khairpur", "Khairpur"),
    ("Kotri", "Kotri"),
    ("Larkana", "Larkana"),
    ("Matiari", "Matiari"),
    ("Mirpur Khas", "Mirpur Khas"),
    ("Mithi", "Mithi"),
    ("Nawabshah", "Nawabshah"),
    ("Naushehro Feroze", "Naushehro Feroze"),
    ("Qambar", "Qambar"),
    ("Sanghar", "Sanghar"),
    ("Shahdadkot", "Shahdadkot"),
    ("Shikarpur", "Shikarpur"),
    ("Sukkur", "Sukkur"),
    ("Tando Adam", "Tando Adam"),
    ("Tando Allahyar", "Tando Allahyar"),
    ("Thatta", "Thatta"),
    ("Umerkot", "Umerkot"),
    # Khyber Pakhtunkhwa
    ("Abbottabad", "Abbottabad"),
    ("Bannu", "Bannu"),
    ("Batagram", "Batagram"),
    ("Buner", "Buner"),
    ("Charsadda", "Charsadda"),
    ("Chitral", "Chitral"),
    ("Dera Ismail Khan", "Dera Ismail Khan"),
    ("Dir", "Dir"),
    ("Haripur", "Haripur"),
    ("Karak", "Karak"),
    ("Kohat", "Kohat"),
    ("Kohistan", "Kohistan"),
    ("Lakki Marwat", "Lakki Marwat"),
    ("Lower Dir", "Lower Dir"),
    ("Malakand", "Malakand"),
    ("Mansehra", "Mansehra"),
    ("Mardan", "Mardan"),
    ("Nowshera", "Nowshera"),
    ("Peshawar", "Peshawar"),
    ("Shangla", "Shangla"),
    ("Swabi", "Swabi"),
    ("Swat", "Swat"),
    ("Tank", "Tank"),
    ("Upper Dir", "Upper Dir"),
    # Balochistan
    ("Awaran", "Awaran"),
    ("Barkhan", "Barkhan"),
    ("Bolan", "Bolan"),
    ("Chagai", "Chagai"),
    ("Dera Bugti", "Dera Bugti"),
    ("Gwadar", "Gwadar"),
    ("Harnai", "Harnai"),
    ("Jafarabad", "Jafarabad"),
    ("Jhal Magsi", "Jhal Magsi"),
    ("Kalat", "Kalat"),
    ("Kech", "Kech"),
    ("Kharan", "Kharan"),
    ("Khuzdar", "Khuzdar"),
    ("Killa Abdullah", "Killa Abdullah"),
    ("Killa Saifullah", "Killa Saifullah"),
    ("Kohlu", "Kohlu"),
    ("Lasbela", "Lasbela"),
    ("Loralai", "Loralai"),
    ("Mastung", "Mastung"),
    ("Musakhel", "Musakhel"),
    ("Nasirabad", "Nasirabad"),
    ("Nushki", "Nushki"),
    ("Panjgur", "Panjgur"),
    ("Pishin", "Pishin"),
    ("Quetta", "Quetta"),
    ("Sherani", "Sherani"),
    ("Sibi", "Sibi"),
    ("Sohbatpur", "Sohbatpur"),
    ("Washuk", "Washuk"),
    ("Zhob", "Zhob"),
    ("Ziarat", "Ziarat"),
    # Islamabad Capital Territory
    ("Islamabad", "Islamabad"),
    # Gilgit-Baltistan
    ("Astore", "Astore"),
    ("Ghizer", "Ghizer"),
    ("Ghanche", "Ghanche"),
    ("Gilgit", "Gilgit"),
    ("Hunza", "Hunza"),
    ("Nagar", "Nagar"),
    ("Skardu", "Skardu"),
    ("Shigar", "Shigar"),
    ("Kharmang", "Kharmang"),
    ("Roundu", "Roundu"),
    # Azad Jammu and Kashmir
    ("Bagh", "Bagh"),
    ("Bhimber", "Bhimber"),
    ("Hattian", "Hattian"),
    ("Haveli", "Haveli"),
    ("Kotli", "Kotli"),
    ("Mirpur", "Mirpur"),
    ("Muzaffarabad", "Muzaffarabad"),
    ("Neelum", "Neelum"),
    ("Poonch", "Poonch"),
    ("Rawalakot", "Rawalakot"),
    ("Sudhanoti", "Sudhanoti"),
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
        extra_fields.setdefault("gender", "Other")
        return self.create_user(email, password, **extra_fields)


# User Model - SINGLE TABLE FOR EVERYTHING
class MyUser(AbstractBaseUser, PermissionsMixin):
    """
    Custom User model for blood donation system.
    All fields directly in this table - no separate lookup tables.
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
            models.Index(fields=["created_at"]),
            models.Index(fields=["blood_group"]),
        ]

    def get_full_name(self) -> str:
        """Return the user's full name."""
        return self.full_name.strip()

    def __str__(self) -> str:
        return self.email


# Donor Model - Uses user_id instead of ForeignKey
class Donor(models.Model):
    """
    Donor profile with blood donation specific information.
    References user by ID instead of ForeignKey.
    """

    id = models.AutoField(primary_key=True)
    user_id = models.IntegerField(
        verbose_name="User ID",
        help_text="Reference to the user account ID",
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
            models.Index(fields=["user_id"]),
            models.Index(fields=["is_available"]),
        ]

    def __str__(self) -> str:
        return f"User ID: {self.user_id}"

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
    user_id = models.IntegerField(
        verbose_name="User ID",
        help_text="Reference to the user account ID",
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
            models.Index(fields=["user_id", "is_used"]),
        ]

    def __str__(self) -> str:
        return f"User ID: {self.user_id} - {self.token}"

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
    user_id = models.IntegerField(
        verbose_name="User ID",
        help_text="Reference to the user account ID",
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
            models.Index(fields=["user_id", "is_used"]),
        ]

    def __str__(self) -> str:
        return f"User ID: {self.user_id} - {self.token}"

    def is_valid(self) -> bool:
        """
        Check if token is valid (not used and not expired - 1 hour).
        Returns True if token can be used for password reset.
        """
        if self.is_used:
            return False
        expiration_time = timezone.now() - timezone.timedelta(hours=1)
        return self.created_at > expiration_time
