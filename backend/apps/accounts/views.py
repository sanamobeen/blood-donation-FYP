# accounts/views.py
import logging
from typing import Dict, Any
from rest_framework import generics, status, permissions, throttling, serializers
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.conf import settings
from .models import MyUser, Donor
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    DonorSerializer,
    DonorRegistrationSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
)

logger = logging.getLogger(__name__)


# Custom throttle classes for auth endpoints
class RegisterRateThrottle(throttling.AnonRateThrottle):
    """Rate limiting for registration endpoint (3 attempts per hour)"""

    rate = "3/hour"
    scope = "register"


class LoginRateThrottle(throttling.AnonRateThrottle):
    """Rate limiting for login endpoint (5 attempts per hour)"""

    rate = "5/hour"
    scope = "login"


def create_api_response(
    message: str, data: Dict[str, Any] = None, status_code: int = status.HTTP_200_OK
) -> Response:
    """
    Create standardized API response format.
    Provides consistent response structure across all endpoints.
    """
    response_data = {"success": True, "message": message, "data": data or {}}
    return Response(response_data, status=status_code)


def create_error_response(
    message: str,
    errors: Dict[str, Any] = None,
    status_code: int = status.HTTP_400_BAD_REQUEST,
) -> Response:
    """
    Create standardized error response format.
    Provides consistent error structure across all endpoints.
    """
    response_data = {"success": False, "message": message, "errors": errors or {}}
    return Response(response_data, status=status_code)


# REGISTER VIEW
class RegisterView(generics.GenericAPIView):
    """
    User registration endpoint.
    Creates new user accounts with optional donor profile.
    Implements rate limiting and comprehensive validation.
    """

    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [RegisterRateThrottle]

    def post(self, request) -> Response:
        """
        Handle user registration POST requests.
        Creates user account, donor profile, and returns authentication tokens.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            user = serializer.save()

            # Create email verification token (optional but recommended)
            from .models import EmailVerification

            verification = EmailVerification.objects.create(user=user)

            # TODO: Send actual email here
            logger.info(
                f"Registration - Verification email for {user.email}: Token = {verification.token}"
            )

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)

            return create_api_response(
                message="User registered successfully. Please check your email to verify your account.",
                data={
                    "user": UserSerializer(user).data,
                    "tokens": {
                        "access": str(refresh.access_token),
                        "refresh": str(refresh),
                    },
                },
                status_code=status.HTTP_201_CREATED,
            )

        except serializers.ValidationError as e:
            logger.warning(f"Registration validation failed: {e.detail}")
            return create_error_response(
                message="Registration failed. Please check your input.",
                errors=e.detail,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        except Exception as e:
            logger.error(
                f"Unexpected error during registration: {str(e)}", exc_info=True
            )
            return create_error_response(
                message="An unexpected error occurred. Please try again later.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# LOGIN VIEW
class LoginView(generics.GenericAPIView):
    """
    User login endpoint.
    Authenticates users and returns JWT tokens.
    Implements rate limiting and security best practices.
    """

    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [LoginRateThrottle]

    def post(self, request) -> Response:
        """
        Handle user login POST requests.
        Authenticates credentials and returns JWT tokens.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            user = serializer.validated_data["user"]

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)

            return create_api_response(
                message="Login successful",
                data={
                    "user": UserSerializer(user).data,
                    "tokens": {
                        "access": str(refresh.access_token),
                        "refresh": str(refresh),
                    },
                },
                status_code=status.HTTP_200_OK,
            )

        except serializers.ValidationError as e:
            logger.warning(f"Login validation failed: {e.detail}")

            # Extract error message from validation error
            if isinstance(e.detail, dict):
                # Check for non_field_errors first (common in validate() method)
                if "non_field_errors" in e.detail:
                    error_list = e.detail["non_field_errors"]
                    # Extract string from ErrorDetail objects
                    error_message = [str(err) for err in error_list]
                # Check for detail field
                elif "detail" in e.detail:
                    error_detail = e.detail["detail"]
                    error_message = [error_detail] if isinstance(error_detail, str) else error_detail
                # Get first field error
                else:
                    first_field_errors = list(e.detail.values())[0]
                    error_message = [str(err) for err in first_field_errors]
            else:
                # e.detail is a list or string
                error_message = [str(e.detail)] if not isinstance(e.detail, list) else [str(err) for err in e.detail]

            return create_error_response(
                message="Login failed. Please check your credentials.",
                errors={"non_field_errors": error_message},
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        except Exception as e:
            logger.error(f"Unexpected login error: {str(e)}", exc_info=True)
            return create_error_response(
                message="An unexpected error occurred during login. Please try again.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# PROFILE VIEW
class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def patch(self, request, *args, **kwargs):
        """Handle partial updates for user profile"""
        return self.partial_update(request, *args, **kwargs)


# REGISTER AS DONOR VIEW
class RegisterAsDonorView(generics.CreateAPIView):
    serializer_class = DonorRegistrationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        donor = serializer.save()

        return Response(
            {
                "message": "Successfully registered as a donor",
                "donor": DonorSerializer(donor).data,
            },
            status=status.HTTP_201_CREATED,
        )


# UPDATE DONOR PROFILE VIEW
class UpdateDonorProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = DonorSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        try:
            return self.request.user.donor_profile
        except Donor.DoesNotExist:
            return Response(
                {"error": "You are not registered as a donor"},
                status=status.HTTP_404_NOT_FOUND,
            )


# LOGOUT VIEW
class LogoutView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if refresh_token:
                token = RefreshToken(refresh_token)
                token.blacklist()
            return Response(
                {"message": "Successfully logged out"}, status=status.HTTP_200_OK
            )
        except Exception as e:
            logger.error(f"Logout error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Invalid token"}, status=status.HTTP_400_BAD_REQUEST
            )


# EMAIL VERIFICATION VIEWS
class SendVerificationEmailView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            user = request.user
            # Delete any existing unused verification tokens
            from .models import EmailVerification
            import uuid

            EmailVerification.objects.filter(user=user, is_used=False).delete()

            # Create new verification token
            verification = EmailVerification.objects.create(user=user)

            # TODO: Send actual email here
            # For now, return the token in response (for testing only)
            logger.info(
                f"Verification email for {user.email}: Token = {verification.token}"
            )

            return Response(
                {
                    "message": "Verification email sent successfully",
                    # "token": str(verification.token),  # Uncomment for testing only
                },
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            logger.error(f"Send verification email error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Failed to send verification email"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class VerifyEmailView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        try:
            from .models import EmailVerification

            token = request.data.get("token")
            if not token:
                return Response(
                    {"error": "Token is required"}, status=status.HTTP_400_BAD_REQUEST
                )

            try:
                verification = EmailVerification.objects.get(token=token)
            except EmailVerification.DoesNotExist:
                return Response(
                    {"error": "Invalid verification token"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if not verification.is_valid():
                return Response(
                    {"error": "Token has expired or already used"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # Mark user as active and verification as used
            verification.user.is_active = True
            verification.user.save()
            verification.is_used = True
            verification.save()

            return Response(
                {"message": "Email verified successfully"}, status=status.HTTP_200_OK
            )

        except Exception as e:
            logger.error(f"Email verification error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Email verification failed"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# FORGOT PASSWORD VIEW
class ForgotPasswordView(generics.GenericAPIView):
    """
    Forgot password endpoint.
    Accepts email and creates a password reset token.
    Sends email with reset link (or returns token for testing).
    Rate limiting disabled for development/testing.
    """
    serializer_class = ForgotPasswordSerializer
    permission_classes = [permissions.AllowAny]
    # throttle_classes = [RegisterRateThrottle]  # Rate limiting disabled

    def post(self, request) -> Response:
        """
        Handle forgot password POST requests.
        Creates password reset token and sends email.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            email = serializer.validated_data["email"]

            # Check if user exists (for security, we always return success)
            try:
                user = MyUser.objects.get(email=email)

                # Delete any existing unused reset tokens for this user
                from .models import PasswordReset

                PasswordReset.objects.filter(user=user, is_used=False).delete()

                # Create new reset token
                reset = PasswordReset.objects.create(user=user)

                # Log the token for development/testing
                logger.info(
                    f"Password reset requested for {email}: Token = {reset.token}"
                )

                # Send actual email
                try:
                    reset_link = f"{settings.FRONTEND_URL}/reset-password?email={email}&token={reset.token}"

                    subject = "Password Reset Request - Blood Donation System"
                    message = f"""
Hello {user.full_name or 'User'},

You recently requested to reset your password for your Blood Donation account.

Click the link below to reset your password:
{reset_link}

This link will expire in 1 hour.

If you didn't request this password reset, please ignore this email.

Best regards,
Blood Donation Team
"""

                    send_mail(
                        subject=subject,
                        message=message,
                        from_email=settings.DEFAULT_FROM_EMAIL,
                        recipient_list=[email],
                        fail_silently=False,
                    )

                    logger.info(f"Password reset email sent successfully to {email}")

                except Exception as email_error:
                    logger.error(f"Failed to send password reset email: {str(email_error)}")
                    # Continue anyway - token is created and can be used manually

                return create_api_response(
                    message="Password reset link has been sent to your email",
                    data={
                        "email": email,
                        # Token is logged in console for development
                        # "token": str(reset.token),  # Uncomment for testing only
                    },
                    status_code=status.HTTP_200_OK,
                )

            except MyUser.DoesNotExist:
                # For security, don't reveal whether email exists
                # Still return success message
                logger.warning(f"Password reset requested for non-existent email: {email}")
                return create_api_response(
                    message="If an account exists with this email, a password reset link has been sent",
                    status_code=status.HTTP_200_OK,
                )

        except serializers.ValidationError as e:
            logger.warning(f"Forgot password validation failed: {e.detail}")
            return create_error_response(
                message="Failed to process forgot password request",
                errors=e.detail,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        except Exception as e:
            logger.error(
                f"Unexpected error during forgot password: {str(e)}", exc_info=True
            )
            return create_error_response(
                message="An unexpected error occurred. Please try again later.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# RESET PASSWORD VIEW
class ResetPasswordView(generics.GenericAPIView):
    """
    Reset password endpoint.
    Accepts email, token, and new password to reset user password.
    Validates token and updates password.
    Rate limiting disabled for development/testing.
    """
    serializer_class = ResetPasswordSerializer
    permission_classes = [permissions.AllowAny]
    # throttle_classes = [RegisterRateThrottle]  # Rate limiting disabled

    def post(self, request) -> Response:
        """
        Handle reset password POST requests.
        Validates token and updates user password.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            user = serializer.validated_data["user"]
            reset = serializer.validated_data["reset"]
            new_password = serializer.validated_data["new_password"]

            # Set new password
            user.set_password(new_password)
            user.save()

            # Mark token as used
            reset.is_used = True
            reset.save()

            # Log password reset
            logger.info(f"Password reset successful for {user.email}")

            return create_api_response(
                message="Password reset successfully. You can now login with your new password",
                status_code=status.HTTP_200_OK,
            )

        except serializers.ValidationError as e:
            logger.warning(f"Reset password validation failed: {e.detail}")
            return create_error_response(
                message="Failed to reset password",
                errors=e.detail,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        except Exception as e:
            logger.error(
                f"Unexpected error during reset password: {str(e)}", exc_info=True
            )
            return create_error_response(
                message="An unexpected error occurred. Please try again later.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
