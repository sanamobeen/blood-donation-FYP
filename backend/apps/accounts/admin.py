from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import MyUser, Donor, EmailVerification, PasswordReset


@admin.register(MyUser)
class MyUserAdmin(UserAdmin):
    model = MyUser

    list_display = ("email", "full_name", "phone", "gender", "province", "district", "blood_group", "is_staff", "is_active")
    search_fields = ("email", "full_name", "phone", "province", "district")
    ordering = ("email",)
    list_filter = ("gender", "province", "blood_group", "is_staff", "is_active")

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (
            "Personal Info",
            {"fields": ("full_name", "phone", "gender", "province", "district", "local_level", "date_of_birth", "blood_group")},
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
        ("Important Dates", {"fields": ("last_login", "date_joined")}),
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
                    "gender",
                    "province",
                    "district",
                    "local_level",
                    "date_of_birth",
                    "blood_group",
                    "password1",
                    "password2",
                    "is_staff",
                    "is_active",
                ),
            },
        ),
    )


@admin.register(Donor)
class DonorAdmin(admin.ModelAdmin):
    list_display = ("user_id", "is_available", "last_donation_date", "total_donations", "created_at")
    search_fields = ("user_id",)
    list_filter = ("is_available", "created_at")
    ordering = ("-created_at",)


@admin.register(EmailVerification)
class EmailVerificationAdmin(admin.ModelAdmin):
    list_display = ("user_id", "token", "is_used", "created_at")
    search_fields = ("user_id", "token")
    list_filter = ("is_used", "created_at")
    ordering = ("-created_at",)
    readonly_fields = ("token", "created_at")


@admin.register(PasswordReset)
class PasswordResetAdmin(admin.ModelAdmin):
    list_display = ("user_id", "token", "is_used", "created_at")
    search_fields = ("user_id", "token")
    list_filter = ("is_used", "created_at")
    ordering = ("-created_at",)
    readonly_fields = ("token", "created_at")
