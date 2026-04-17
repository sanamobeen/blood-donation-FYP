# accounts/views.py
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .models import MyUser, Donor
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    DonorSerializer,
    DonorRegistrationSerializer
)


# REGISTER VIEW
class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]  # Allow unauthenticated access

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)

        return Response({
            "message": "User registered successfully",
            "user": UserSerializer(user).data,
            "access": str(refresh.access_token),
            "refresh": str(refresh),
        }, status=status.HTTP_201_CREATED)


# LOGIN VIEW
class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]  # Allow unauthenticated access

    def post(self, request):
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            user = serializer.validated_data['user']

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)

            return Response({
                "message": "Login successful",
                "user": UserSerializer(user).data,
                "access": str(refresh.access_token),
                "refresh": str(refresh),
            }, status=status.HTTP_200_OK)

        except serializers.ValidationError as e:
            # Return error format expected by Flutter app
            return Response({
                "non_field_errors": e.detail.get('detail', [str(e.detail)]) if isinstance(e.detail, dict) else [str(e.detail)]
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                "non_field_errors": ["An error occurred during login"]
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# PROFILE VIEW
class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


# REGISTER AS DONOR VIEW
class RegisterAsDonorView(generics.CreateAPIView):
    serializer_class = DonorRegistrationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        donor = serializer.save()

        return Response({
            "message": "Successfully registered as a donor",
            "donor": DonorSerializer(donor).data,
        }, status=status.HTTP_201_CREATED)


# UPDATE DONOR PROFILE VIEW
class UpdateDonorProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = DonorSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        try:
            return self.request.user.donor_profile
        except Donor.DoesNotExist:
            raise Response({
                "error": "You are not registered as a donor"
            }, status=status.HTTP_404_NOT_FOUND)