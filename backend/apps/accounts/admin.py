from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import MyUser


@admin.register(MyUser)
class MyUserAdmin(UserAdmin):
    model = MyUser

    list_display = ("email", "full_name", "phone", "is_staff", "is_active")
    search_fields = ("email", "full_name", "phone")
    ordering = ("email",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (
            "Personal Info",
            {"fields": ("full_name", "phone", "province", "district", "local_level", "gender", "date_of_birth")},
        ),
        (
            "Status",
            {
                "fields": (
                    "is_staff",
                    "is_active",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        ("Important Dates", {"fields": ("last_login",)}),
    )

    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "email",
                    "full_name",
                    "phone",
                    "province",
                    "district",
                    "local_level",
                    "gender",
                    "password1",
                    "password2",
                    "is_staff",
                    "is_active",
                ),
            },
        ),
    )
