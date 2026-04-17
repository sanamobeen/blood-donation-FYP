from django.contrib.auth.backends import BaseBackend
from .models import MyUser


class EmailBackend(BaseBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = MyUser.objects.get(email=username)
        except MyUser.DoesNotExist:
            return None

        if user.check_password(password):
            return user
        return None
