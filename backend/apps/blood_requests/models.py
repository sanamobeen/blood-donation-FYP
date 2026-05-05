from django.db import models

# Integer-based choices for API efficiency
BLOOD_GROUP_CHOICES = [
    (1, "A+"),
    (2, "A-"),
    (3, "B+"),
    (4, "B-"),
    (5, "AB+"),
    (6, "AB-"),
    (7, "O+"),
    (8, "O-"),
]

GENDER_CHOICES = [
    (1, "Male"),
    (2, "Female"),
    (3, "Other"),
]

PROVINCE_CHOICES = [
    (1, "Punjab"),
    (2, "Sindh"),
    (3, "Khyber Pakhtunkhwa"),
    (4, "Balochistan"),
    (5, "Gilgit Baltistan"),
    (6, "Azad Kashmir"),
    (7, "Islamabad Capital Territory"),
]

REQUEST_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("partially_fulfilled", "Partially Fulfilled"),
    ("completed", "Completed"),
    ("cancelled", "Cancelled"),
]


class BloodRequest(models.Model):
    id = models.AutoField(primary_key=True)
    user_id = models.IntegerField()
    patient_name = models.CharField(max_length=100)
    emergency_contact = models.CharField(max_length=15)
    blood_group = models.IntegerField(choices=BLOOD_GROUP_CHOICES, default=1)  # A+ as default
    gender = models.IntegerField(choices=GENDER_CHOICES, default=1)  # Male as default
    province = models.IntegerField(choices=PROVINCE_CHOICES, default=1)  # Punjab as default
    district = models.CharField(max_length=100, blank=True, null=True)
    local_level = models.CharField(max_length=200, blank=True, null=True)
    units_required = models.IntegerField()
    required_date = models.DateField(blank=True, null=True)
    required_time = models.TimeField(blank=True, null=True)
    case = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=30, choices=REQUEST_STATUS, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.patient_name} - {self.blood_group} ({self.status})"
