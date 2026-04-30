# blood_requests/urls.py
from django.urls import path
from .views import (
    BloodRequestCreateView,
    BloodRequestListView,
    MyBloodRequestsView,
    BloodRequestDetailView,
)

urlpatterns = [
    path("create/", BloodRequestCreateView.as_view(), name="create_blood_request"),
    path("", BloodRequestListView.as_view(), name="blood_request_list"),
    path("my-requests/", MyBloodRequestsView.as_view(), name="my_blood_requests"),
    path("<int:pk>/", BloodRequestDetailView.as_view(), name="blood_request_detail"),
]
