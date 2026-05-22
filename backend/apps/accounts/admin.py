from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, UserProfile, Donor, EmailVerification, PasswordReset


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    model = CustomUser

    list_display = ("email", "full_name", "phone", "has_password", "is_staff", "is_active", "date_joined")
    search_fields = ("email", "full_name", "phone")
    ordering = ("email",)
    list_filter = ("is_staff", "is_active", "date_joined")
    readonly_fields = ("date_joined",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        (
            "Personal Info",
            {"fields": ("full_name", "phone")},
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
                    "password1",
                    "password2",
                    "is_staff",
                    "is_active",
                ),
            },
        ),
    )

    def has_password(self, obj):
        """Show if user has a password set"""
        return bool(obj.password)
    has_password.short_description = "Password Set"
    has_password.boolean = True


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("user_email", "get_full_name", "blood_group", "gender", "province", "district", "created_at")
    search_fields = ("user__email", "user__full_name", "province", "district")
    list_filter = ("gender", "province", "blood_group", "created_at")
    ordering = ("-created_at",)

    def user_email(self, obj):
        return obj.user.email

    def get_full_name(self, obj):
        return obj.user.get_full_name()


@admin.register(Donor)
class DonorAdmin(admin.ModelAdmin):
    list_display = ("user_email", "is_available", "last_donation_date", "total_donations", "created_at")
    search_fields = ("user__email",)
    list_filter = ("is_available", "created_at")
    ordering = ("-created_at",)

    def user_email(self, obj):
        return obj.user.email


@admin.register(EmailVerification)
class EmailVerificationAdmin(admin.ModelAdmin):
    list_display = ("user_email", "token", "is_used", "created_at")
    search_fields = ("user__email", "token")
    list_filter = ("is_used", "created_at")
    ordering = ("-created_at",)
    readonly_fields = ("token", "created_at")

    def user_email(self, obj):
        return obj.user.email


@admin.register(PasswordReset)
class PasswordResetAdmin(admin.ModelAdmin):
    list_display = ("user_email", "token", "is_used", "created_at")
    search_fields = ("user__email", "token")
    list_filter = ("is_used", "created_at")
    ordering = ("-created_at",)
    readonly_fields = ("token", "created_at")

    def user_email(self, obj):
        return obj.user.email
