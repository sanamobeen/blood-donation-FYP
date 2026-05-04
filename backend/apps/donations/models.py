from django.db import models

DONATION_STATUS = [
    ("pending", "Pending"),
    ("accepted", "Accepted"),
    ("rejected", "Rejected"),
    ("completed", "Completed"),
]


class Donation(models.Model):
    id = models.AutoField(primary_key=True)
    donor_id = models.IntegerField()
    request_id = models.IntegerField()
    status = models.CharField(max_length=20, choices=DONATION_STATUS, default="pending")
    donation_date = models.DateField(blank=True, null=True)
    units_donated = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Donation by donor ID {self.donor_id} for request ID {self.request_id}"
