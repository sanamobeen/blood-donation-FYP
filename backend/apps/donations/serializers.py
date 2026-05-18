from rest_framework import serializers
from .models import Donation


class DonationSerializer(serializers.ModelSerializer):
    donor_email = serializers.EmailField(source="donor.email", read_only=True)
    donor_full_name = serializers.CharField(source="donor.get_full_name", read_only=True)

    class Meta:
        model = Donation
        fields = [
            "id",
            "donor",
            "donor_email",
            "donor_full_name",
            "request_id",
            "status",
            "donation_date",
            "units_donated",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at", "donor"]

    def validate_units_donated(self, value):
        if value <= 0:
            raise serializers.ValidationError("Units donated must be greater than 0")
        return value

    def create(self, validated_data):
        # Set the donor to the current user
        user = self.context["request"].user
        validated_data["donor"] = user
        return super().create(validated_data)


class DonationListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing donations"""
    status_display = serializers.CharField(source="get_status_display", read_only=True)
    donor_email = serializers.EmailField(source="donor.email", read_only=True)

    class Meta:
        model = Donation
        fields = [
            "id",
            "donor",
            "donor_email",
            "request_id",
            "status",
            "status_display",
            "units_donated",
            "donation_date",
            "created_at",
        ]
