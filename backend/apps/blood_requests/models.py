from django.db import models
from apps.accounts.models import MyUser, BLOOD_GROUPS, URGENCY_LEVELS

REQUEST_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("partially_fulfilled", "Partially Fulfilled"),
    ("completed", "Completed"),
    ("cancelled", "Cancelled"),
]


class BloodRequest(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(
        MyUser, on_delete=models.CASCADE, related_name="blood_requests"
    )
    patient_name = models.CharField(max_length=100)
    emergency_contact = models.CharField(max_length=15)
    blood_group = models.CharField(max_length=3, choices=BLOOD_GROUPS)
    units_required = models.IntegerField()
    urgency_level = models.CharField(max_length=20, choices=URGENCY_LEVELS)
    city = models.CharField(max_length=100)
    hospital_name = models.CharField(max_length=200)
    status = models.CharField(max_length=30, choices=REQUEST_STATUS, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.patient_name} - {self.blood_group} ({self.status})"
