from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.db.models import Q, F, ExpressionWrapper, FloatField
from django.db.models.functions import Abs, Cos, Radians, Sin, Sqrt
from .models import CustomUser, UserProfile, Donor
from .serializers_donor_search import DonorSearchSerializer
import math


def haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    Returns distance in kilometers
    """
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))

    # Radius of earth in kilometers
    r = 6371
    return c * r


@api_view(['GET'])
@permission_classes([AllowAny])
def find_donors_nearby(request):
    """
    Find donors near a given location within a specified radius.

    Query Parameters:
    - latitude: Required. Patient's latitude
    - longitude: Required. Patient's longitude
    - radius_km: Optional. Search radius in kilometers (default: 50, max: 200)
    - blood_group: Optional. Filter by blood group (e.g., 'A+', 'B-', etc.)

    Returns:
    - List of donors with their distance from the patient
    """
    latitude = request.query_params.get('latitude')
    longitude = request.query_params.get('longitude')
    radius_km = request.query_params.get('radius_km', 50)
    blood_group = request.query_params.get('blood_group')

    # Validate required parameters
    if not latitude or not longitude:
        return Response(
            {
                'success': False,
                'message': 'Latitude and longitude are required parameters'
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        latitude = float(latitude)
        longitude = float(longitude)
        radius_km = float(radius_km)

        # Validate coordinate ranges
        if not -90 <= latitude <= 90:
            return Response(
                {'success': False, 'message': 'Latitude must be between -90 and 90'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not -180 <= longitude <= 180:
            return Response(
                {'success': False, 'message': 'Longitude must be between -180 and 180'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Limit maximum radius
        radius_km = min(radius_km, 200)

    except (ValueError, TypeError):
        return Response(
            {'success': False, 'message': 'Invalid numeric values for coordinates or radius'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Validate blood group if provided
    valid_blood_groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
    if blood_group and blood_group not in valid_blood_groups:
        return Response(
            {
                'success': False,
                'message': f'Invalid blood group. Must be one of: {", ".join(valid_blood_groups)}'
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    # Query users with donor profiles and valid coordinates
    donors_query = CustomUser.objects.filter(
        blood_profile__isnull=False,
        blood_profile__latitude__isnull=False,
        blood_profile__longitude__isnull=False,
    ).select_related('blood_profile', 'donor_profile')

    # Filter by blood group if specified
    if blood_group:
        donors_query = donors_query.filter(
            blood_profile__blood_group=blood_group
        )

    # Get all donors with coordinates and calculate distances
    donors_data = []
    for donor in donors_query:
        donor_lat = float(donor.blood_profile.latitude)
        donor_lon = float(donor.blood_profile.longitude)

        # Calculate distance using Haversine formula
        distance = haversine_distance(latitude, longitude, donor_lat, donor_lon)

        # Only include donors within the specified radius
        if distance <= radius_km:
            donor_data = DonorSearchSerializer(donor).data
            donor_data['distance_km'] = round(distance, 2)
            donor_data['latitude'] = donor_lat
            donor_data['longitude'] = donor_lon
            donors_data.append(donor_data)

    # Sort by distance (nearest first)
    donors_data.sort(key=lambda x: x['distance_km'])

    return Response({
        'success': True,
        'data': {
            'donors': donors_data,
            'count': len(donors_data),
            'search_center': {
                'latitude': latitude,
                'longitude': longitude,
                'radius_km': radius_km
            },
            'filters': {
                'blood_group': blood_group or 'All'
            }
        },
        'message': f'Found {len(donors_data)} donor(s) within {radius_km} km'
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def donor_search_filters(request):
    """
    Get available filter options for donor search.
    Returns list of blood groups and other filter options.
    """
    return Response({
        'success': True,
        'data': {
            'blood_groups': [
                {'value': 'A+', 'label': 'A+'},
                {'value': 'A-', 'label': 'A-'},
                {'value': 'B+', 'label': 'B+'},
                {'value': 'B-', 'label': 'B-'},
                {'value': 'AB+', 'label': 'AB+'},
                {'value': 'AB-', 'label': 'AB-'},
                {'value': 'O+', 'label': 'O+'},
                {'value': 'O-', 'label': 'O-'},
            ],
            'radius_options': [
                {'value': 10, 'label': '10 km'},
                {'value': 20, 'label': '20 km'},
                {'value': 50, 'label': '50 km'},
                {'value': 100, 'label': '100 km'},
                {'value': 200, 'label': '200 km'},
            ]
        }
    })
