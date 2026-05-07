from rest_framework import generics, status, permissions, filters, views
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import BloodRequest, BLOOD_GROUP_CHOICES, GENDER_CHOICES, PROVINCE_CHOICES, DISTRICT_CHOICES
from .serializers import BloodRequestSerializer, BloodRequestListSerializer


class BloodRequestCreateView(generics.CreateAPIView):
    serializer_class = BloodRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        blood_request = serializer.save()

        return Response(
            {
                "message": "Blood request created successfully",
                "blood_request": BloodRequestSerializer(blood_request).data,
            },
            status=status.HTTP_201_CREATED,
        )


class BloodRequestListView(generics.ListAPIView):
    serializer_class = BloodRequestListSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ["blood_group", "status", "province", "district", "gender"]
    ordering_fields = ["created_at", "required_date", "units_required"]
    ordering = ["-created_at"]

    def get_queryset(self):
        return BloodRequest.objects.all()


class MyBloodRequestsView(generics.ListAPIView):
    serializer_class = BloodRequestListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return BloodRequest.objects.filter(user_id=self.request.user.id)


class BloodRequestDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = BloodRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return BloodRequest.objects.filter(user_id=self.request.user.id)


# Location Data Endpoints for Frontend Dropdowns
class ProvincesView(views.APIView):
    """Get list of provinces for dropdown (string-based like registration)"""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        provinces = [{"id": choice[0], "name": choice[1]} for choice in PROVINCE_CHOICES]
        return Response(provinces)


class DistrictsView(views.APIView):
    """Get list of districts (string-based like registration) - filtered by province if provided"""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        province_id = request.query_params.get("province", None)

        # Get all districts
        all_districts = [{"id": district[0], "name": district[1]} for district in DISTRICT_CHOICES]

        # Filter by province if provided
        if province_id:
            # Define province-district mappings
            province_districts = self._get_districts_by_province(province_id)
            filtered_districts = [d for d in all_districts if d["id"] in province_districts]
            return Response(filtered_districts)

        return Response(all_districts)

    def _get_districts_by_province(self, province_id):
        """Get list of district names for a given province"""
        # Organize districts by province based on the DISTRICT_CHOICES structure
        province_map = {
            "Punjab": [],
            "Sindh": [],
            "Khyber Pakhtunkhwa": [],
            "Balochistan": [],
            "Islamabad Capital Territory": [],
            "Gilgit-Baltistan": [],
            "Azad Jammu and Kashmir": []
        }

        current_province = None
        for district in DISTRICT_CHOICES:
            district_name = district[0]

            # Punjab districts
            if district_name in ["Ahmedpur East", "Arifwala", "Attock", "Bahawalnagar", "Bahawalpur",
                                "Bhakkar", "Burewala", "Chakwal", "Chiniot", "Dera Ghazi Khan", "Faisalabad",
                                "Ferozewala", "Gujranwala", "Gujrat", "Hafizabad", "Jhang", "Jhelum", "Kasur",
                                "Khanewal", "Khushab", "Lahore", "Layyah", "Lodhran", "Mandi Bahauddin",
                                "Mianwali", "Multan", "Muzaffargarh", "Nankana Sahib", "Narowal", "Okara",
                                "Pakpattan", "Rahim Yar Khan", "Rajanpur", "Rawalpindi", "Sahiwal", "Sargodha",
                                "Sheikhupura", "Sialkot", "Toba Tek Singh", "Vehari", "Wazirabad"]:
                current_province = "Punjab"
                province_map["Punjab"].append(district_name)

            # Sindh districts
            elif district_name in ["Badin", "Bhan", "Chachro", "Dadu", "Diplo", "Ghotki", "Hyderabad",
                                  "Jacobabad", "Jamshoro", "Karachi", "Kashmore", "Kandhkot", "Khairpur", "Kotri",
                                  "Larkana", "Matiari", "Mirpur Khas", "Mithi", "Nawabshah", "Naushehro Feroze",
                                  "Qambar", "Sanghar", "Shahdadkot", "Shikarpur", "Sukkur", "Tando Adam",
                                  "Tando Allahyar", "Thatta", "Umerkot"]:
                current_province = "Sindh"
                province_map["Sindh"].append(district_name)

            # Khyber Pakhtunkhwa districts
            elif district_name in ["Abbottabad", "Bannu", "Batagram", "Buner", "Charsadda", "Chitral",
                                  "Dera Ismail Khan", "Dir", "Haripur", "Karak", "Kohat", "Kohistan",
                                  "Lakki Marwat", "Lower Dir", "Malakand", "Mansehra", "Mardan", "Nowshera",
                                  "Peshawar", "Shangla", "Swabi", "Swat", "Tank", "Upper Dir"]:
                current_province = "Khyber Pakhtunkhwa"
                province_map["Khyber Pakhtunkhwa"].append(district_name)

            # Balochistan districts
            elif district_name in ["Awaran", "Barkhan", "Bolan", "Chagai", "Dera Bugti", "Gwadar",
                                  "Harnai", "Jafarabad", "Jhal Magsi", "Kalat", "Kech", "Kharan", "Khuzdar",
                                  "Killa Abdullah", "Killa Saifullah", "Kohlu", "Lasbela", "Loralai", "Mastung",
                                  "Musakhel", "Nasirabad", "Nushki", "Panjgur", "Pishin", "Quetta", "Sherani",
                                  "Sibi", "Sohbatpur", "Washuk", "Zhob", "Ziarat"]:
                current_province = "Balochistan"
                province_map["Balochistan"].append(district_name)

            # Islamabad Capital Territory
            elif district_name == "Islamabad":
                current_province = "Islamabad Capital Territory"
                province_map["Islamabad Capital Territory"].append(district_name)

            # Gilgit-Baltistan districts
            elif district_name in ["Astore", "Ghizer", "Ghanche", "Gilgit", "Hunza", "Nagar", "Skardu",
                                  "Shigar", "Kharmang", "Roundu"]:
                current_province = "Gilgit-Baltistan"
                province_map["Gilgit-Baltistan"].append(district_name)

            # Azad Jammu and Kashmir districts
            elif district_name in ["Bagh", "Bhimber", "Hattian", "Haveli", "Kotli", "Mirpur",
                                  "Muzaffarabad", "Neelum", "Poonch", "Rawalakot", "Sudhanoti"]:
                current_province = "Azad Jammu and Kashmir"
                province_map["Azad Jammu and Kashmir"].append(district_name)

        return province_map.get(province_id, [])


class LocalLevelsView(views.APIView):
    """Get list of local levels for a district (placeholder for future expansion)"""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        district_id = request.query_params.get("district", None)

        # For now, return generic local levels (you can expand this based on district)
        all_local_levels = [
            {"id": 1, "name": "Tehsil 1"},
            {"id": 2, "name": "Tehsil 2"},
            {"id": 3, "name": "Union Council 1"},
            {"id": 4, "name": "Union Council 2"},
        ]

        if district_id:
            # You can filter local levels by district here in the future
            pass

        return Response(all_local_levels)


class BloodGroupsView(views.APIView):
    """Get list of blood groups for dropdown (string-based like registration)"""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        # Convert integer blood groups to strings to match registration model
        blood_group_strings = [
            {"id": "A+", "name": "A+"},
            {"id": "A-", "name": "A-"},
            {"id": "B+", "name": "B+"},
            {"id": "B-", "name": "B-"},
            {"id": "AB+", "name": "AB+"},
            {"id": "AB-", "name": "AB-"},
            {"id": "O+", "name": "O+"},
            {"id": "O-", "name": "O-"},
        ]
        return Response(blood_group_strings)


class GendersView(views.APIView):
    """Get list of genders for dropdown (string-based like registration)"""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        # Convert integer genders to strings to match registration model
        gender_strings = [
            {"id": "Male", "name": "Male"},
            {"id": "Female", "name": "Female"},
            {"id": "Other", "name": "Other"},
        ]
        return Response(gender_strings)
