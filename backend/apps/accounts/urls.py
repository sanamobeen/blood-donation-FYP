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
    ForgotPasswordView,
    ResetPasswordView,
    ProvinceListView,
    DistrictListView,
    LocalLevelListView,
    GenderListView,
    BloodGroupListView,
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
    path("forgot-password/", ForgotPasswordView.as_view(), name="forgot_password"),
    path("reset-password/", ResetPasswordView.as_view(), name="reset_password"),
    # Location endpoints
    path("locations/provinces/", ProvinceListView.as_view(), name="province_list"),
    path("locations/districts/", DistrictListView.as_view(), name="district_list"),
    path("locations/local-levels/", LocalLevelListView.as_view(), name="local_level_list"),
    path("locations/genders/", GenderListView.as_view(), name="gender_list"),
    path("locations/blood-groups/", BloodGroupListView.as_view(), name="blood_group_list"),
]
