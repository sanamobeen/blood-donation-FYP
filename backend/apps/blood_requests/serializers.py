from rest_framework import serializers
from .models import BloodRequest
from apps.accounts.models import BLOOD_GROUPS, URGENCY_LEVELS


class BloodRequestSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source="user.email", read_only=True)
    user_name = serializers.CharField(source="user.get_full_name", read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user",
            "user_email",
            "user_name",
            "patient_name",
            "emergency_contact",
            "blood_group",
            "units_required",
            "urgency_level",
            "city",
            "hospital_name",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "user", "status", "created_at", "updated_at"]

    def validate_units_required(self, value):
        if value <= 0:
            raise serializers.ValidationError("Units required must be greater than 0")
        return value

    def create(self, validated_data):
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)


class BloodRequestListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing requests"""

    user_name = serializers.CharField(source="user.get_full_name", read_only=True)
    blood_group_display = serializers.CharField(
        source="get_blood_group_display", read_only=True
    )
    urgency_level_display = serializers.CharField(
        source="get_urgency_level_display", read_only=True
    )
    status_display = serializers.CharField(source="get_status_display", read_only=True)

    class Meta:
        model = BloodRequest
        fields = [
            "id",
            "user_name",
            "patient_name",
            "blood_group",
            "blood_group_display",
            "units_required",
            "urgency_level",
            "urgency_level_display",
            "city",
            "hospital_name",
            "status",
            "status_display",
            "created_at",
        ]
