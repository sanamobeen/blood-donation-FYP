# accounts/urls.py
from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    ProfileView,
    RegisterAsDonorView,
    UpdateDonorProfileView,
    LogoutView,
    SendVerificationEmailView,
    VerifyEmailView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", LoginView.as_view(), name="login"),
    path("logout/", LogoutView.as_view(), name="logout"),
    path("profile/", ProfileView.as_view(), name="profile"),
    path("donor/register/", RegisterAsDonorView.as_view(), name="register_as_donor"),
    path(
        "donor/profile/", UpdateDonorProfileView.as_view(), name="update_donor_profile"
    ),
    path("verify/send/", SendVerificationEmailView.as_view(), name="send_verification"),
    path("verify/", VerifyEmailView.as_view(), name="verify_email"),
]
