from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import Specialization, User


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    fieldsets = DjangoUserAdmin.fieldsets + (
        ("Rôle et contact", {"fields": ("role", "phone", "specialization", "marketplace_visible")}),
    )
    list_display = ("username", "email", "role", "specialization", "marketplace_visible")
    list_filter = ("role", "marketplace_visible")


@admin.register(Specialization)
class SpecializationAdmin(admin.ModelAdmin):
    search_fields = ("name",)
    list_display = ("name",)
