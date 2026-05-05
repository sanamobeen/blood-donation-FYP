from django.core.management.base import BaseCommand
from apps.accounts.models import BloodGroup


class Command(BaseCommand):
    help = 'Populate BloodGroup data'

    def handle(self, *args, **options):
        # Clear existing data
        BloodGroup.objects.all().delete()

        # Create BloodGroups
        blood_groups_data = [
            {"name": "A+"},
            {"name": "A-"},
            {"name": "B+"},
            {"name": "B-"},
            {"name": "AB+"},
            {"name": "AB-"},
            {"name": "O+"},
            {"name": "O-"},
        ]

        for data in blood_groups_data:
            blood_group = BloodGroup.objects.create(**data)
            self.stdout.write(f'Created BloodGroup: {blood_group.name}')

        self.stdout.write(self.style.SUCCESS('Successfully populated blood group data'))
