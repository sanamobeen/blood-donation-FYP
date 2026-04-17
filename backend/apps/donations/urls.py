# donations/urls.py
from django.urls import path
from .views import (
    DonationCreateView,
    DonationListView,
    MyDonationsView,
    AcceptDonationView
)

urlpatterns = [
    path("create/", DonationCreateView.as_view(), name="create_donation"),
    path("", DonationListView.as_view(), name="donation_list"),
    path("my-donations/", MyDonationsView.as_view(), name="my_donations"),
    path("<int:pk>/accept/", AcceptDonationView.as_view(), name="accept_donation"),
]