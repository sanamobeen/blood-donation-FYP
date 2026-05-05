from django.core.management.base import BaseCommand
from apps.accounts.models import Province, District, LocalLevel, Gender, BloodGroup


class Command(BaseCommand):
    help = 'Populate lookup tables for Gender, Province, District, LocalLevel, and BloodGroup'

    def handle(self, *args, **kwargs):
        self.stdout.write('Populating lookup tables...')

        # Populate Gender
        genders = ['Male', 'Female', 'Other']
        for gender_name in genders:
            obj, created = Gender.objects.get_or_create(name=gender_name)
            if created:
                self.stdout.write(f'Created Gender: {gender_name}')

        # Populate Blood Groups
        blood_groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
        for bg in blood_groups:
            obj, created = BloodGroup.objects.get_or_create(name=bg)
            if created:
                self.stdout.write(f'Created BloodGroup: {bg}')

        # Populate Provinces
        provinces_data = {
            'Punjab': 'PB',
            'Sindh': 'SD',
            'Khyber Pakhtunkhwa': 'KP',
            'Balochistan': 'BL',
            'Gilgit Baltistan': 'GB',
            'Azad Kashmir': 'AK',
            'Islamabad Capital Territory': 'IS'
        }

        provinces = {}
        for province_name, code in provinces_data.items():
            obj, created = Province.objects.get_or_create(name=province_name, code=code)
            provinces[province_name] = obj
            if created:
                self.stdout.write(f'Created Province: {province_name}')

        # Populate Districts for Punjab (sample - add more as needed)
        punjab_districts = [
            'Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala',
            'Sialkot', 'Sargodha', 'Bahawalpur', 'Gujrat', 'Jhang',
            'Sheikhupura', 'Kasur', 'Mianwali', 'Sahiwal', 'Okara'
        ]

        for district_name in punjab_districts:
            obj, created = District.objects.get_or_create(
                name=district_name,
                province=provinces['Punjab']
            )
            if created:
                self.stdout.write(f'Created District: {district_name} (Punjab)')

        # Populate Districts for Sindh (sample)
        sindh_districts = [
            'Karachi', 'Hyderabad', 'Sukkur', 'Larkana', 'Mirpurkhas', 'Nawabshah'
        ]

        for district_name in sindh_districts:
            obj, created = District.objects.get_or_create(
                name=district_name,
                province=provinces['Sindh']
            )
            if created:
                self.stdout.write(f'Created District: {district_name} (Sindh)')

        # Populate Districts for Khyber Pakhtunkhwa (sample)
        kp_districts = [
            'Peshawar', 'Mardan', 'Swat', 'Abbottabad', 'Kohat', 'Dera Ismail Khan'
        ]

        for district_name in kp_districts:
            obj, created = District.objects.get_or_create(
                name=district_name,
                province=provinces['Khyber Pakhtunkhwa']
            )
            if created:
                self.stdout.write(f'Created District: {district_name} (KP)')

        # Populate LocalLevels for Lahore (sample)
        lahore_tehsils = [
            'Johar Town', 'Gulberg', 'DHA', 'Model Town', 'Iqbal Town',
            'Samanabad', 'Shadman', 'Cantt', 'Walled City', 'Garden Town'
        ]

        lahore_district = District.objects.filter(name='Lahore').first()
        if lahore_district:
            for local_level_name in lahore_tehsils:
                obj, created = LocalLevel.objects.get_or_create(
                    name=local_level_name,
                    district=lahore_district
                )
                if created:
                    self.stdout.write(f'Created LocalLevel: {local_level_name} (Lahore)')

        self.stdout.write(self.style.SUCCESS('Successfully populated lookup tables!'))
