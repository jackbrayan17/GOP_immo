from django.contrib.auth import views as auth_views
from django.urls import path

from . import views

urlpatterns = [
    path("connexion/", auth_views.LoginView.as_view(template_name="accounts/login.html"), name="login"),
    path("deconnexion/", auth_views.LogoutView.as_view(), name="logout"),
    path("inscription/", views.signup_choice, name="signup_choice"),
    path("inscription/proprietaire/", views.proprietaire_signup, name="proprietaire_signup"),
    path("inscription/prestataire/", views.prestataire_signup, name="prestataire_signup"),
    path("profil/", views.profile, name="profile"),
]
