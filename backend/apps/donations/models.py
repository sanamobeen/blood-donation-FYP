from django.db import models
from apps.accounts.models import Donor
from apps.blood_requests.models import BloodRequest

DONATION_STATUS = [
    ('pending', 'Pending'),
    ('accepted', 'Accepted'),
    ('rejected', 'Rejected'),
    ('completed', 'Completed'),
]


class Donation(models.Model):
    id = models.AutoField(primary_key=True)
    donor = models.ForeignKey(Donor, on_delete=models.CASCADE, related_name='donations')
    request = models.ForeignKey(BloodRequest, on_delete=models.CASCADE, related_name='donations')
    status = models.CharField(max_length=20, choices=DONATION_STATUS, default='pending')
    donation_date = models.DateField(blank=True, null=True)
    units_donated = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Donation by {self.donor.user.email} for {self.request.patient_name}"