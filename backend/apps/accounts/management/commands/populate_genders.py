from django.core.management.base import BaseCommand
from apps.accounts.models import Gender


class Command(BaseCommand):
    help = 'Populate Gender data'

    def handle(self, *args, **options):
        # Clear existing data
        Gender.objects.all().delete()

        # Create Genders
        genders_data = [
            {"name": "Male"},
            {"name": "Female"},
            {"name": "Other"},
        ]

        for data in genders_data:
            gender = Gender.objects.create(**data)
            self.stdout.write(f'Created Gender: {gender.name}')

        self.stdout.write(self.style.SUCCESS('Successfully populated gender data'))
