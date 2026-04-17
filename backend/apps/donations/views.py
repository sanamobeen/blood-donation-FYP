from rest_framework import generics, status, permissions, filters
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Donation
from .serializers import DonationSerializer, DonationListSerializer
from apps.accounts.models import Donor


class DonationCreateView(generics.CreateAPIView):
    serializer_class = DonationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        donation = serializer.save()

        return Response({
            "message": "Donation record created successfully",
            "donation": DonationListSerializer(donation).data,
        }, status=status.HTTP_201_CREATED)


class DonationListView(generics.ListAPIView):
    serializer_class = DonationListSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'donation_date']
    ordering_fields = ['created_at', 'donation_date']
    ordering = ['-created_at']

    def get_queryset(self):
        return Donation.objects.all()


class MyDonationsView(generics.ListAPIView):
    serializer_class = DonationListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        try:
            donor = self.request.user.donor_profile
            return Donation.objects.filter(donor=donor)
        except Donor.DoesNotExist:
            return Donation.objects.none()


class AcceptDonationView(generics.UpdateAPIView):
    serializer_class = DonationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        try:
            donation = Donation.objects.get(pk=pk)
        except Donation.DoesNotExist:
            return Response({
                "error": "Donation record not found"
            }, status=status.HTTP_404_NOT_FOUND)

        # Check if the current user is the donor
        if donation.donor.user != request.user:
            return Response({
                "error": "You can only accept your own donation requests"
            }, status=status.HTTP_403_FORBIDDEN)

        # Update donation status
        donation.status = 'accepted'
        donation.save()

        return Response({
            "message": "Donation accepted successfully",
            "donation": DonationListSerializer(donation).data,
        }, status=status.HTTP_200_OK)