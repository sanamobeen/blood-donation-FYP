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
from .models import CustomUser, UserProfile, Donor
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    UpdateProfileSerializer,
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
    Creates pending registration and sends verification email.
    User is only created after email verification.
    Rate limiting disabled for development.
    """

    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    # throttle_classes = [RegisterRateThrottle]  # Disabled for development

    def post(self, request) -> Response:
        """
        Handle user registration POST requests.
        Creates pending registration, sends verification email.
        User account is created only after email verification.
        """
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            errors = serializer.errors
            # Get the first error message
            error_msg = "Registration failed"
            for field, messages in errors.items():
                if isinstance(messages, list):
                    error_msg = messages[0] if messages else "Registration failed"
                else:
                    error_msg = messages
                break

            return create_error_response(
                message=error_msg,
                errors=errors,
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Extract validated data
            email = serializer.validated_data.get('email', '').lower()
            password = serializer.validated_data.get('password', '')
            full_name = serializer.validated_data.get('full_name', '')
            phone = serializer.validated_data.get('phone', '')

            # Check if email already exists (either as user or pending)
            from .models import CustomUser, PendingRegistration

            if CustomUser.objects.filter(email=email).exists():
                return create_error_response(
                    message="An account with this email already exists. Please login.",
                    status_code=status.HTTP_400_BAD_REQUEST,
                )

            if PendingRegistration.objects.filter(email=email, is_verified=False).exists():
                # Delete old pending registration and create new one
                PendingRegistration.objects.filter(email=email, is_verified=False).delete()

            # Create pending registration
            pending = PendingRegistration(
                email=email,
                password=password,  # Will be hashed by the model's create_user method
                full_name=full_name,
                phone=phone,
            )
            pending.save()  # This generates the verification code

            # Send verification email
            try:
                verification_link = f"{settings.FRONTEND_URL}verify-email?code={pending.verification_code}"

                subject = "Verify Your Email - Blood Donation System"
                message = f"""Hello {full_name or 'User'},

Thank you for registering with the Blood Donation System!

Please verify your email address using your verification code:

Your verification code is: {pending.verification_code}

This code will expire in 24 hours.

Or click the link below (if deep linking is enabled):
{verification_link}

If you didn't create an account with us, please ignore this email.

Best regards,
Blood Donation Team"""

                send_mail(
                    subject=subject,
                    message=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[email],
                    fail_silently=False,
                )

                logger.info(f"Verification email sent successfully to {email}")

            except Exception as email_error:
                logger.error(f"Failed to send verification email during registration: {str(email_error)}")
                return create_error_response(
                    message=f"Failed to send verification email: {str(email_error)}",
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            return create_api_response(
                message="Registration initiated. Please check your email to verify your account.",
                data={
                    "email": email,
                    "message": "Please verify your email to complete registration",
                },
                status_code=status.HTTP_201_CREATED,
            )

        except Exception as e:
            logger.error(
                f"Unexpected error during registration: {str(e)}", exc_info=True
            )
            return create_error_response(
                message=f"Registration failed: {str(e)}",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
                # Email verification link will still be included in response for testing

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)

            return create_api_response(
                message="User registered successfully. Please check your email to verify your account.",
                data={
                    "user": {
                        "id": user.id,
                        "email": user.email,
                        "full_name": user.full_name,
                        "phone": user.phone,
                        "is_verified": user.is_verified,
                    },
                    "tokens": {
                        "access": str(refresh.access_token),
                        "refresh": str(refresh),
                    },
                },
                status_code=status.HTTP_201_CREATED,
            )

        except Exception as e:
            logger.error(
                f"Unexpected error during registration: {str(e)}", exc_info=True
            )
            return create_error_response(
                message=f"Registration failed: {str(e)}",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# LOGIN VIEW
class LoginView(generics.GenericAPIView):
    """
    User login endpoint.
    Authenticates users and returns JWT tokens.
    Rate limiting disabled for development.
    """

    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]
    # throttle_classes = [LoginRateThrottle]  # Disabled for development

    def post(self, request) -> Response:
        """
        Handle user login POST requests.
        Authenticates credentials and returns JWT tokens.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            user = serializer.validated_data["user"]
            email_not_verified = serializer.validated_data.get("email_not_verified", False)

            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)

            # Prepare response message
            message = "Login successful"
            if email_not_verified:
                message = "Login successful. Please verify your email to access all features."

            return create_api_response(
                message=message,
                data={
                    "user": {
                        "id": user.id,
                        "email": user.email,
                        "full_name": user.full_name,
                        "phone": user.phone,
                        "is_verified": user.is_verified,
                        "email_not_verified": email_not_verified,
                    },
                    "tokens": {
                        "access": str(refresh.access_token),
                        "refresh": str(refresh),
                    },
                },
                status_code=status.HTTP_200_OK,
            )

            return create_api_response(
                message="Login successful",
                data={
                    "user": {
                        "id": user.id,
                        "email": user.email,
                        "full_name": user.full_name,
                        "phone": user.phone,
                    },
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
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        """Use UpdateProfileSerializer for updates, UserSerializer for reads"""
        if self.request.method in ['PUT', 'PATCH']:
            return UpdateProfileSerializer
        return UserSerializer

    def get_object(self):
        # Get or create user profile
        user = self.request.user
        UserProfile.objects.get_or_create(user=user)
        return user

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
            return Donor.objects.get(user=self.request.user)
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
            # Delete any existing unused verification codes
            from .models import EmailVerification

            EmailVerification.objects.filter(user=user, is_used=False).delete()

            # Create new verification code
            verification = EmailVerification.objects.create(user=user)

            # Send actual verification email
            try:
                verification_link = f"{settings.FRONTEND_URL}verify-email?code={verification.code}"

                subject = "Verify Your Email - Blood Donation System"
                full_name = user.get_full_name()
                message = f"""Hello {full_name or 'User'},

Please verify your email address using your verification code:

Your verification code is: {verification.code}

This code will expire in 24 hours.

Or click the link below (if deep linking is enabled):
{verification_link}

If you didn't create an account with us, please ignore this email.

Best regards,
Blood Donation Team"""

                send_mail(
                    subject=subject,
                    message=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[user.email],
                    fail_silently=False,
                )

                logger.info(f"Verification email sent successfully to {user.email}")

            except Exception as email_error:
                logger.error(f"Failed to send verification email: {str(email_error)}")
                return Response(
                    {"error": f"Failed to send verification email: {str(email_error)}"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            # Build response
            response_data = {
                "message": "Verification email sent successfully",
                "email": user.email,
            }

            # Include code for testing in debug mode
            if settings.DEBUG:
                response_data["code"] = verification.code
                response_data["verification_link"] = f"{settings.FRONTEND_URL}verify-email?code={verification.code}"

            return Response(
                response_data,
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
            from .models import EmailVerification, PendingRegistration

            code = request.data.get("code")
            if not code:
                return Response(
                    {"error": "Verification code is required"}, status=status.HTTP_400_BAD_REQUEST
                )

            # First check if this is a pending registration verification
            try:
                pending = PendingRegistration.objects.get(verification_code=code, is_verified=False)

                if not pending.is_valid():
                    return Response(
                        {"error": "Code has expired"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                # Create the user from pending registration
                user = pending.create_user()

                # Mark pending registration as verified
                pending.is_verified = True
                pending.save()

                # Generate JWT tokens for the new user
                refresh = RefreshToken.for_user(user)

                logger.info(f"Email verified and user created: {user.email}")

                return Response(
                    {
                        "success": True,
                        "message": "Email verified successfully. Your account has been created.",
                        "email": user.email,
                        "user": {
                            "id": user.id,
                            "email": user.email,
                            "full_name": user.full_name,
                            "phone": user.phone,
                            "is_verified": user.is_verified,
                        },
                        "tokens": {
                            "access": str(refresh.access_token),
                            "refresh": str(refresh),
                        },
                    },
                    status=status.HTTP_200_OK
                )

            except PendingRegistration.DoesNotExist:
                # Check if it's an existing user's email verification (for users who already exist)
                try:
                    verification = EmailVerification.objects.get(code=code)
                except EmailVerification.DoesNotExist:
                    return Response(
                        {"error": "Invalid verification code"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                if not verification.is_valid():
                    return Response(
                        {"error": "Code has expired or already used"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                # Mark user email as verified and verification as used
                user = verification.user
                user.is_verified = True
                user.save()
                verification.is_used = True
                verification.save()

                logger.info(f"Email verified successfully for {user.email}")

                return Response(
                    {
                        "success": True,
                        "message": "Email verified successfully",
                        "email": user.email,
                    },
                    status=status.HTTP_200_OK
                )

        except Exception as e:
            logger.error(f"Email verification error: {str(e)}", exc_info=True)
            return Response(
                {"error": "Email verification failed"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


# TEST ENDPOINT - Get verification codes (for development/testing only)
class GetVerificationTokensView(generics.GenericAPIView):
    """
    Development-only endpoint to get all verification codes.
    Remove this in production!
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        if not settings.DEBUG:
            return Response(
                {"error": "This endpoint is only available in DEBUG mode"},
                status=status.HTTP_403_FORBIDDEN,
            )

        from .models import EmailVerification

        verifications = EmailVerification.objects.filter(is_used=False).order_by('-created_at')[:10]

        data = []
        for v in verifications:
            data.append({
                "email": v.user.email,
                "code": v.code,
                "created_at": v.created_at.isoformat(),
                "is_used": v.is_used,
                "verification_link": f"{settings.FRONTEND_URL}verify-email?code={v.code}",
                "api_endpoint": f"/api/accounts/verify/",
                "api_payload": {"code": v.code},
            })

        return Response({
            "message": "Latest verification codes (for testing)",
            "count": len(data),
            "data": data
        })


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
        Only works for emails that exist in the system.
        """
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            email = serializer.validated_data["email"]

            # Get user (serializer already validated email exists)
            user = CustomUser.objects.get(email=email)

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
                full_name = user.get_full_name()
                message = f"""
Hello {full_name or 'User'},

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

            # Build response data
            response_data = {"email": email}

            # Include token only in development mode for testing
            if settings.DEBUG:
                response_data["token"] = str(reset.token)

            return create_api_response(
                message="Password reset link has been sent to your email",
                data=response_data,
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


