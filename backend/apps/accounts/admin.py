from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import MyUser, Province, District, LocalLevel, Gender, BloodGroup


@admin.register(BloodGroup)
class BloodGroupAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)
    ordering = ("name",)


@admin.register(Gender)
class GenderAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)
    ordering = ("name",)


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


@admin.register(Province)
class ProvinceAdmin(admin.ModelAdmin):
    list_display = ("name", "code")
    search_fields = ("name", "code")
    ordering = ("name",)


@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ("name", "province")
    list_filter = ("province",)
    search_fields = ("name", "province__name")
    ordering = ("province", "name")


@admin.register(LocalLevel)
class LocalLevelAdmin(admin.ModelAdmin):
    list_display = ("name", "district")
    list_filter = ("district",)
    search_fields = ("name", "district__name")
    ordering = ("district", "name")

