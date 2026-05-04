from rest_framework import serializers
from .models import Donation


class DonationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Donation
        fields = [
            "id",
            "donor_id",
            "request_id",
            "status",
            "donation_date",
            "units_donated",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def validate_units_donated(self, value):
        if value <= 0:
            raise serializers.ValidationError("Units donated must be greater than 0")
        return value

    def create(self, validated_data):
        # Set the donor_id to the current user's id
        user = self.context["request"].user
        validated_data["donor_id"] = user.id
        return super().create(validated_data)


class DonationListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing donations"""
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = Donation
        fields = [
            "id",
            "donor_id",
            "request_id",
            "status",
            "status_display",
            "units_donated",
            "donation_date",
            "created_at",
        ]
