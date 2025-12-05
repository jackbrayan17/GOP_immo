from django import forms
from django.contrib.auth.forms import UserCreationForm

from .models import Specialization, User


def specialization_queryset():
    return Specialization.objects.all()


class ProprietaireSignupForm(UserCreationForm):
    phone = forms.CharField(label="Téléphone", required=False)

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ["username", "email", "phone"]

    def save(self, commit=True):
        user: User = super().save(commit=False)
        user.role = User.Role.PROPRIETAIRE
        if commit:
            user.save()
        return user


class PrestataireSignupForm(UserCreationForm):
    phone = forms.CharField(label="Téléphone", required=False)
    specialization = forms.ModelChoiceField(
        label="Spécialisation",
        queryset=Specialization.objects.none(),
        required=True,
        empty_label="Choisir une spécialisation",
    )
    marketplace_visible = forms.BooleanField(
        label="Visible sur le marketplace",
        required=False,
        initial=True,
    )

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ["username", "email", "phone", "specialization", "marketplace_visible"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        qs = specialization_queryset()
        self.fields["specialization"].queryset = qs
        if not qs.exists():
            self.fields["specialization"].empty_label = "Aucune spécialisation enregistrée"

    def save(self, commit=True):
        user: User = super().save(commit=False)
        user.role = User.Role.PRESTATAIRE
        selected = self.cleaned_data.get("specialization")
        user.specialization = selected.name if selected else ""
        user.marketplace_visible = self.cleaned_data.get("marketplace_visible", True)
        if commit:
            user.save()
        return user


class ProfileForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ["email", "phone", "specialization", "marketplace_visible"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        qs = specialization_queryset()
        if qs.exists():
            self.fields["specialization"] = forms.ModelChoiceField(
                queryset=qs,
                required=False,
                label="Spécialisation",
                empty_label="Choisir une spécialisation",
                initial=None,
            )
            if isinstance(self.instance, User) and self.instance.specialization:
                self.fields["specialization"].initial = qs.filter(name=self.instance.specialization).first()

    def save(self, commit=True):
        user: User = super().save(commit=False)
        selected = self.cleaned_data.get("specialization")
        if isinstance(selected, Specialization):
            user.specialization = selected.name
        if commit:
            user.save()
        return user
