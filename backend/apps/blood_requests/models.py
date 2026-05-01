from django.db import models
from apps.accounts.models import MyUser, Province, District, LocalLevel, Gender, BloodGroup

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
    blood_group = models.ForeignKey(
        BloodGroup, on_delete=models.CASCADE, related_name="blood_requests"
    )
    gender = models.ForeignKey(
        Gender, on_delete=models.CASCADE, related_name="blood_requests"
    )
    province = models.ForeignKey(
        Province, on_delete=models.CASCADE, related_name="blood_requests", blank=True, null=True
    )
    district = models.ForeignKey(
        District, on_delete=models.CASCADE, related_name="blood_requests", blank=True, null=True
    )
    local_level = models.ForeignKey(
        LocalLevel, on_delete=models.CASCADE, related_name="blood_requests", blank=True, null=True
    )
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
