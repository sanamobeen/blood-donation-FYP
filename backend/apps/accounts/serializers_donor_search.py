from rest_framework import serializers
from .models import CustomUser, UserProfile, Donor


class DonorSearchSerializer(serializers.ModelSerializer):
    """Serializer for donor search results with location data"""
    blood_group = serializers.CharField(source='blood_profile.blood_group', allow_null=True)
    is_available = serializers.BooleanField(source='donor_profile.is_available', default=True)
    latitude = serializers.FloatField(source='blood_profile.latitude', allow_null=True)
    longitude = serializers.FloatField(source='blood_profile.longitude', allow_null=True)
    distance_km = serializers.FloatField(read_only=True, required=False)
    local_level = serializers.CharField(source='blood_profile.local_level', allow_null=True)
    district = serializers.CharField(source='blood_profile.district', allow_null=True)
    province = serializers.CharField(source='blood_profile.province', allow_null=True)

    class Meta:
        model = CustomUser
        fields = [
            'id',
            'email',
            'full_name',
            'phone',
            'gender',
            'blood_group',
            'is_available',
            'latitude',
            'longitude',
            'distance_km',
            'local_level',
            'district',
            'province',
        ]
