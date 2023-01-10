from django.apps import AppConfig


class UserConfig(AppConfig):
    name = 'user'

    def ready(self):
        from user.models import User
        admin_user = User.objects.filter(is_superuser=True)
        if not admin_user.exists():
            User.objects.create_user(
                username="admin",
                email="admin@admin.com",
                password="ubuntu",
                is_staff=True,
                is_superuser=True
            )
