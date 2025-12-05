from django.contrib.auth import get_user_model

from .models import Specialization

DEFAULT_SPECIALIZATIONS = ["Plomberie", "Menuiserie", "Carrelage"]


def create_default_superuser(sender, **kwargs):
    """
    Ensure the requested default admin exists after migrations.
    """
    User = get_user_model()
    username = "admin0000"
    password = "admin0000"
    if not User.objects.filter(username=username).exists():
        User.objects.create_superuser(username=username, email="admin@gp-immo.test", password=password)

    for name in DEFAULT_SPECIALIZATIONS:
        Specialization.objects.get_or_create(name=name)
