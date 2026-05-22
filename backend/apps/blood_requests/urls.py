# blood_requests/urls.py
from django.urls import path
from .views import (
    BloodRequestCreateView,
    BloodRequestListView,
    MyBloodRequestsView,
    BloodRequestDetailView,
    ProvincesView,
    DistrictsView,
    LocalLevelsView,
    BloodGroupsView,
    GendersView,
)

urlpatterns = [
    # Main CRUD endpoints
    path("create/", BloodRequestCreateView.as_view(), name="create_blood_request"),
    path("", BloodRequestListView.as_view(), name="blood_request_list"),
    path("my-requests/", MyBloodRequestsView.as_view(), name="my_blood_requests"),
    path("<int:pk>/", BloodRequestDetailView.as_view(), name="blood_request_detail"),

    # Location data endpoints for frontend dropdowns
    path("provinces/", ProvincesView.as_view(), name="provinces"),
    path("districts/", DistrictsView.as_view(), name="districts"),
    path("local-levels/", LocalLevelsView.as_view(), name="local_levels"),
    path("blood-groups/", BloodGroupsView.as_view(), name="blood_groups"),
    path("genders/", GendersView.as_view(), name="genders"),
]