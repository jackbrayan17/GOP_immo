from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        PROPRIETAIRE = "PROPRIETAIRE", "Propriétaire"
        PRESTATAIRE = "PRESTATAIRE", "Prestataire"
        STAFF = "STAFF", "Equipe"

    phone = models.CharField(max_length=30, blank=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.PROPRIETAIRE)
    specialization = models.CharField(max_length=100, blank=True)
    marketplace_visible = models.BooleanField(default=True)

    def is_proprietaire(self) -> bool:
        return self.role == self.Role.PROPRIETAIRE

    def is_prestataire(self) -> bool:
        return self.role == self.Role.PRESTATAIRE

    def display_name(self) -> str:
        base = self.get_full_name().strip() or self.username
        if self.is_prestataire() and self.specialization:
            return f"{base} - {self.specialization}"
        return base

    def __str__(self) -> str:
        return self.display_name()


class Specialization(models.Model):
    name = models.CharField(max_length=120, unique=True)

    class Meta:
        ordering = ["name"]

    def __str__(self) -> str:
        return self.name
