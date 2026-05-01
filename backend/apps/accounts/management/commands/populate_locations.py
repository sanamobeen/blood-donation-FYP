from django.core.management.base import BaseCommand
from apps.accounts.models import Province, District, LocalLevel


class Command(BaseCommand):
    help = 'Populate Province, District, and LocalLevel data'

    def handle(self, *args, **options):
        # Clear existing data
        LocalLevel.objects.all().delete()
        District.objects.all().delete()
        Province.objects.all().delete()

        # Create Provinces
        provinces_data = [
            {"name": "Punjab", "code": "PB"},
            {"name": "Sindh", "code": "SD"},
            {"name": "Khyber Pakhtunkhwa", "code": "KP"},
            {"name": "Balochistan", "code": "BA"},
        ]

        provinces = {}
        for data in provinces_data:
            province = Province.objects.create(**data)
            provinces[province.name] = province
            self.stdout.write(f'Created Province: {province.name}')

        # Create Districts
        districts_data = [
            # Punjab Districts
            {"province": provinces["Punjab"], "name": "Lahore"},
            {"province": provinces["Punjab"], "name": "Faisalabad"},
            {"province": provinces["Punjab"], "name": "Rawalpindi"},
            {"province": provinces["Punjab"], "name": "Multan"},
            {"province": provinces["Punjab"], "name": "Gujranwala"},
            {"province": provinces["Punjab"], "name": "Sialkot"},
            {"province": provinces["Punjab"], "name": "Sargodha"},
            {"province": provinces["Punjab"], "name": "Bahawalpur"},
            {"province": provinces["Punjab"], "name": "Dera Ghazi Khan"},
            {"province": provinces["Punjab"], "name": "Sheikhupura"},
            # Sindh Districts
            {"province": provinces["Sindh"], "name": "Karachi"},
            {"province": provinces["Sindh"], "name": "Hyderabad"},
            {"province": provinces["Sindh"], "name": "Sukkur"},
            {"province": provinces["Sindh"], "name": "Larkana"},
            {"province": provinces["Sindh"], "name": "Mirpurkhas"},
            {"province": provinces["Sindh"], "name": "Nawabshah"},
            # KPK Districts
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Peshawar"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Mardan"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Swat"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Abbottabad"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Mingora"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Kohat"},
            {"province": provinces["Khyber Pakhtunkhwa"], "name": "Dera Ismail Khan"},
            # Balochistan Districts
            {"province": provinces["Balochistan"], "name": "Quetta"},
            {"province": provinces["Balochistan"], "name": "Gwadar"},
            {"province": provinces["Balochistan"], "name": "Turbat"},
            {"province": provinces["Balochistan"], "name": "Sibi"},
            {"province": provinces["Balochistan"], "name": "Loralai"},
        ]

        districts = {}
        for data in districts_data:
            district = District.objects.create(**data)
            districts[f"{data['province'].name}_{data['name']}"] = district
            self.stdout.write(f'Created District: {district.name}, {district.province.name}')

        # Create some sample LocalLevels
        local_levels_data = [
            # Lahore local levels
            {"district": districts["Punjab_Lahore"], "name": "Gulberg"},
            {"district": districts["Punjab_Lahore"], "name": "DHA Defence"},
            {"district": districts["Punjab_Lahore"], "name": "Johar Town"},
            {"district": districts["Punjab_Lahore"], "name": "Model Town"},
            {"district": districts["Punjab_Lahore"], "name": "Walled City"},
            # Karachi local levels
            {"district": districts["Sindh_Karachi"], "name": "Clifton"},
            {"district": districts["Sindh_Karachi"], "name": "Gulshan"},
            {"district": districts["Sindh_Karachi"], "name": "North Nazimabad"},
            {"district": districts["Sindh_Karachi"], "name": "Bahadurabad"},
            {"district": districts["Sindh_Karachi"], "name": "Liaquatabad"},
            # Peshawar local levels
            {"district": districts["Khyber Pakhtunkhwa_Peshawar"], "name": "University Town"},
            {"district": districts["Khyber Pakhtunkhwa_Peshawar"], "name": "Cantonment"},
            {"district": districts["Khyber Pakhtunkhwa_Peshawar"], "name": "Hayatabad"},
            {"district": districts["Khyber Pakhtunkhwa_Peshawar"], "name": "Faizabad"},
            # Quetta local levels
            {"district": districts["Balochistan_Quetta"], "name": "Jinnah Town"},
            {"district": districts["Balochistan_Quetta"], "name": "Almo Chowk"},
            {"district": districts["Balochistan_Quetta"], "name": "Satellite Town"},
            {"district": districts["Balochistan_Quetta"], "name": "Brewery Road"},
        ]

        for data in local_levels_data:
            local_level = LocalLevel.objects.create(**data)
            self.stdout.write(
                f'Created LocalLevel: {local_level.name}, {local_level.district.name}, '
                f'{local_level.district.province.name}'
            )

        self.stdout.write(self.style.SUCCESS('Successfully populated location data'))
