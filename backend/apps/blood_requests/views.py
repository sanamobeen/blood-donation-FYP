from rest_framework import generics, status, permissions, filters
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import BloodRequest
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
        return BloodRequest.objects.filter(user=self.request.user)


class BloodRequestDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = BloodRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return BloodRequest.objects.filter(user=self.request.user)
