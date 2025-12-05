from django.conf import settings
from django.conf.urls.static import static
from django.urls import path

from . import views

urlpatterns = [
    path("", views.home, name="home"),
    path("dashboard/", views.dashboard, name="dashboard"),
    path("biens/", views.biens_list, name="biens_list"),
    path("biens/nouveau/", views.bien_create, name="bien_create"),
    path("biens/<int:pk>/edition/", views.bien_edit, name="bien_edit"),
    path("biens/<int:pk>/medias/", views.bien_media, name="bien_media"),
    path("biens/<int:pk>/prestataire/", views.assign_prestataire, name="assign_prestataire"),
    path("contrats/nouveau/", views.contract_create, name="contract_create"),
    path("paiements/nouveau/", views.payment_create, name="payment_create"),
    path("marketplace/prestataires/", views.marketplace, name="marketplace"),
    path("messagerie/", views.inbox, name="inbox"),
    path("messagerie/<int:user_id>/", views.conversation, name="conversation"),
    path("rapports/nouveau/", views.report_create, name="report_create"),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
