from rest_framework import serializers
from .models import Donation
from apps.accounts.models import Donor


class DonationSerializer(serializers.ModelSerializer):
    donor_email = serializers.EmailField(source="donor.user.email", read_only=True)
    donor_name = serializers.CharField(
        source="donor.user.get_full_name", read_only=True
    )
    donor_blood_group = serializers.CharField(
        source="donor.blood_group", read_only=True
    )
    patient_name = serializers.CharField(source="request.patient_name", read_only=True)
    blood_group = serializers.CharField(source="request.blood_group", read_only=True)

    class Meta:
        model = Donation
        fields = [
            "id",
            "donor",
            "donor_email",
            "donor_name",
            "donor_blood_group",
            "request",
            "patient_name",
            "blood_group",
            "status",
            "donation_date",
            "units_donated",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "donor", "created_at", "updated_at"]

    def validate_units_donated(self, value):
        if value <= 0:
            raise serializers.ValidationError("Units donated must be greater than 0")
        return value

    def create(self, validated_data):
        # Set the donor to the current user's donor profile
        user = self.context["request"].user
        try:
            donor = user.donor_profile
        except Donor.DoesNotExist:
            raise serializers.ValidationError("You must register as a donor first")

        validated_data["donor"] = donor
        return super().create(validated_data)


class DonationListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing donations"""

    donor_name = serializers.CharField(
        source="donor.user.get_full_name", read_only=True
    )
    donor_blood_group = serializers.CharField(
        source="donor.blood_group", read_only=True
    )
    patient_name = serializers.CharField(source="request.patient_name", read_only=True)
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = Donation
        fields = [
            "id",
            "donor_name",
            "donor_blood_group",
            "patient_name",
            "status",
            "status_display",
            "units_donated",
            "donation_date",
            "created_at",
        ]
