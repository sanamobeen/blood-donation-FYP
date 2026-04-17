from django.db import models
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)
from django.utils import timezone

# Choices
GENDERS = [
    ("Male", "Male"),
    ("Female", "Female"),
    ("Other", "Other"),
]

ROLE_CHOICES = [
    ('patient', 'Patient'),
    ('donor', 'Donor'),
    ('admin', 'Admin'),
]

BLOOD_GROUPS = [
    ('A+', 'A+'),
    ('A-', 'A-'),
    ('B+', 'B+'),
    ('B-', 'B-'),
    ('AB+', 'AB+'),
    ('AB-', 'AB-'),
    ('O+', 'O+'),
    ('O-', 'O-'),
]

URGENCY_LEVELS = [
    ('low', 'Low'),
    ('medium', 'Medium'),
    ('high', 'High - Critical'),
]

REQUEST_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('partially_fulfilled', 'Partially Fulfilled'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
]

DONATION_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('rejected', 'Rejected'),
    ('completed', 'Completed'),
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
        return self.create_user(email, password, **extra_fields)

# User Model
class MyUser(AbstractBaseUser, PermissionsMixin):
    id = models.AutoField(primary_key=True)
    full_name = models.CharField(max_length=100)  # Combined first and last name
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)  # Hashed password
    phone = models.CharField(max_length=15)
    city = models.CharField(max_length=100)  # Required field (will store province from frontend)
    gender = models.CharField(max_length=6, choices=GENDERS)  # Required field - no null/blank
    date_of_birth = models.DateField(blank=True, null=True)  # New field for date of birth
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='patient')  # Role: patient, donor, or admin
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    objects = MyUserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["full_name", "phone", "city", "gender"]

    def get_full_name(self):
        return self.full_name.strip()

    def __str__(self):
        return self.email


# Donor Model
class Donor(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.OneToOneField(MyUser, on_delete=models.CASCADE, related_name='donor_profile')
    blood_group = models.CharField(max_length=3, choices=BLOOD_GROUPS)
    is_available = models.BooleanField(default=True)
    last_donation_date = models.DateField(blank=True, null=True)
    total_donations = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.blood_group}"