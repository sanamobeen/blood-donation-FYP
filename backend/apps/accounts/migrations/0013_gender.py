# Generated migration for Gender model

import django.db.models.deletion
from django.db import migrations, models


def create_genders(apps, schema_editor):
    """Create Gender records"""
    Gender = apps.get_model("accounts", "Gender")

    # Create Gender records
    Gender.objects.create(name="Male")
    Gender.objects.create(name="Female")
    Gender.objects.create(name="Other")


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0011_province_district_locallevel"),
    ]

    operations = [
        migrations.CreateModel(
            name="Gender",
            fields=[
                ("id", models.AutoField(primary_key=True, serialize=False)),
                ("name", models.CharField(max_length=10, unique=True)),
            ],
            options={
                "verbose_name": "Gender",
                "verbose_name_plural": "Genders",
                "ordering": ["name"],
            },
        ),
        migrations.RunPython(create_genders, migrations.RunPython.noop),
    ]
