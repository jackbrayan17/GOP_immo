from django import forms

from accounts.models import User
from .models import Bien, BienMedia, Contract, InterventionReport, Message, Payment, PrestataireAssignment


class MultiFileInput(forms.ClearableFileInput):
    allow_multiple_selected = True


class BienForm(forms.ModelForm):
    class Meta:
        model = Bien
        fields = [
            "title",
            "property_type",
            "listing_status",
            "furnished",
            "price",
            "address",
            "description",
        ]


class PrestataireAssignmentForm(forms.ModelForm):
    prestataire = forms.ModelChoiceField(
        queryset=User.objects.filter(role=User.Role.PRESTATAIRE, marketplace_visible=True),
        label="Prestataire",
    )

    class Meta:
        model = PrestataireAssignment
        fields = ["prestataire"]


class ContractForm(forms.ModelForm):
    class Meta:
        model = Contract
        fields = ["bien", "tenant_name", "start_date", "end_date", "rent", "status"]


class PaymentForm(forms.ModelForm):
    class Meta:
        model = Payment
        fields = ["contract", "bien", "prestataire", "amount", "due_date", "status", "payment_type"]


class MessageForm(forms.ModelForm):
    class Meta:
        model = Message
        fields = ["content", "attachment", "kind"]
        widgets = {
            "content": forms.Textarea(attrs={"rows": 2, "placeholder": "Ecrire un message..."}),
        }


class InterventionReportForm(forms.ModelForm):
    class Meta:
        model = InterventionReport
        fields = ["bien", "summary", "attachment"]


class BienMediaUploadForm(forms.Form):
    files = forms.FileField(
        label="Photos/Videos",
        widget=MultiFileInput(attrs={"multiple": True}),
        help_text="Jusqu'a 10 fichiers (images ou videos).",
        required=True,
    )

    def clean_files(self):
        files = self.files.getlist("files")
        if not files:
            raise forms.ValidationError("Ajoutez au moins un fichier.")
        if len(files) > 10:
            raise forms.ValidationError("Maximum 10 fichiers par envoi.")
        allowed_prefixes = ("image/", "video/")
        for f in files:
            ctype = getattr(f, "content_type", "") or ""
            if not ctype.startswith(allowed_prefixes):
                raise forms.ValidationError("Seules les images ou videos sont acceptees.")
        return files
