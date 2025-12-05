from django.conf import settings
from django.db import models
from django.utils import timezone


class Bien(models.Model):
    class PropertyType(models.TextChoices):
        APPARTEMENT_LOCATION = "APPARTEMENT_LOCATION", "Appartement en location"
        APPARTEMENT_MEUBLE = "APPARTEMENT_MEUBLE", "Appartement meublé"
        STUDIO_LOCATION = "STUDIO_LOCATION", "Studio en location"
        STUDIO_MEUBLE = "STUDIO_MEUBLE", "Studio meublé"
        CHAMBRE_LOCATION = "CHAMBRE_LOCATION", "Chambre en location"
        CHAMBRE_MEUBLE = "CHAMBRE_MEUBLE", "Chambre meublée"
        MAGASIN = "MAGASIN", "Magasin"
        IMMEUBLE = "IMMEUBLE", "Immeuble"
        MAISON = "MAISON", "Maison"

    class ListingStatus(models.TextChoices):
        LOCATION = "LOCATION", "À louer"
        VENTE = "VENTE", "À vendre"

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="biens",
    )
    title = models.CharField(max_length=120)
    property_type = models.CharField(max_length=40, choices=PropertyType.choices)
    listing_status = models.CharField(
        max_length=20,
        choices=ListingStatus.choices,
        default=ListingStatus.LOCATION,
    )
    furnished = models.BooleanField(default=False)
    price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    address = models.CharField(max_length=255, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.get_listing_status_display()})"


def bien_media_upload_to(instance, filename):
    timestamp = timezone.now().strftime("%Y%m%d%H%M%S")
    return f"biens/{instance.bien_id}/{timestamp}_{filename}"


class BienMedia(models.Model):
    bien = models.ForeignKey(Bien, on_delete=models.CASCADE, related_name="media")
    file = models.FileField(upload_to=bien_media_upload_to)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class MediaKind(models.TextChoices):
        IMAGE = "IMAGE", "Image"
        VIDEO = "VIDEO", "Vidéo"
        AUTRE = "AUTRE", "Autre"

    def kind(self):
        content_type = getattr(self.file, "file", None)
        if content_type and hasattr(content_type, "content_type"):
            ct = content_type.content_type
            if ct.startswith("image/"):
                return self.MediaKind.IMAGE
            if ct.startswith("video/"):
                return self.MediaKind.VIDEO
        return self.MediaKind.AUTRE

    def __str__(self):
        return f"Media {self.bien} - {self.file.name}"


class PrestataireAssignment(models.Model):
    bien = models.ForeignKey(Bien, on_delete=models.CASCADE, related_name="prestataires")
    prestataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="missions",
    )
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("bien", "prestataire")

    def __str__(self):
        return f"{self.prestataire} -> {self.bien}"


class Contract(models.Model):
    class Status(models.TextChoices):
        DRAFT = "DRAFT", "Brouillon"
        ACTIVE = "ACTIVE", "Actif"
        CLOSED = "CLOSED", "Terminé"

    bien = models.ForeignKey(Bien, on_delete=models.CASCADE, related_name="contrats")
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="contrats",
    )
    tenant_name = models.CharField(max_length=120)
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    rent = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.DRAFT)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Contrat {self.tenant_name} - {self.bien}"


class Payment(models.Model):
    class PaymentType(models.TextChoices):
        LOYER = "LOYER", "Loyer"
        RESERVATION = "RESERVATION", "Réservation"
        PRESTATAIRE = "PRESTATAIRE", "Prestataire"

    class Status(models.TextChoices):
        PENDING = "PENDING", "En attente"
        PAID = "PAID", "Payé"
        LATE = "LATE", "Retard"

    contract = models.ForeignKey(Contract, null=True, blank=True, on_delete=models.CASCADE, related_name="paiements")
    bien = models.ForeignKey(Bien, null=True, blank=True, on_delete=models.CASCADE, related_name="paiements")
    prestataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="paiements_recus",
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    due_date = models.DateField(default=timezone.now)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    payment_type = models.CharField(max_length=20, choices=PaymentType.choices)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.payment_type} - {self.amount} €"


def message_upload_to(instance, filename):
    return f"messages/{instance.sender_id}/{timezone.now().strftime('%Y%m%d%H%M%S')}_{filename}"


class Message(models.Model):
    class Kind(models.TextChoices):
        TEXTE = "TEXTE", "Message"
        DEVIS = "DEVIS", "Devis"
        PREUVE = "PREUVE", "Preuve d'intervention"

    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="messages_envoyes")
    receiver = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="messages_recus")
    content = models.TextField(blank=True)
    attachment = models.FileField(upload_to=message_upload_to, null=True, blank=True)
    kind = models.CharField(max_length=10, choices=Kind.choices, default=Kind.TEXTE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Message de {self.sender} à {self.receiver}"


def report_upload_to(instance, filename):
    return f"rapports/{instance.prestataire_id}/{timezone.now().strftime('%Y%m%d%H%M%S')}_{filename}"


class InterventionReport(models.Model):
    bien = models.ForeignKey(Bien, on_delete=models.CASCADE, related_name="rapports")
    prestataire = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="rapports_realises",
    )
    summary = models.TextField()
    attachment = models.FileField(upload_to=report_upload_to, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Rapport {self.bien} - {self.prestataire}"
