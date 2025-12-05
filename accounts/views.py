from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render

from .forms import PrestataireSignupForm, ProfileForm, ProprietaireSignupForm
from .models import User


def signup_choice(request):
    return render(request, "accounts/signup_choice.html")


def proprietaire_signup(request):
    if request.method == "POST":
        form = ProprietaireSignupForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, "Bienvenue ! Profil propriétaire créé.")
            return redirect("dashboard")
    else:
        form = ProprietaireSignupForm()
    return render(request, "accounts/signup.html", {"form": form, "role": "Propriétaire"})


def prestataire_signup(request):
    if request.method == "POST":
        form = PrestataireSignupForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, "Compte prestataire créé.")
            return redirect("dashboard")
    else:
        form = PrestataireSignupForm()
    return render(request, "accounts/signup.html", {"form": form, "role": "Prestataire"})


@login_required
def profile(request):
    user: User = request.user
    if request.method == "POST":
        form = ProfileForm(request.POST, instance=user)
        if form.is_valid():
            form.save()
            messages.success(request, "Profil mis à jour.")
            return redirect("profile")
    else:
        form = ProfileForm(instance=user)
    return render(request, "accounts/profile.html", {"form": form})
