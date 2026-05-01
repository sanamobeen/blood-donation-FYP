# Generated migration for BloodGroup data

from django.db import migrations


def create_blood_groups(apps, schema_editor):
    """Create BloodGroup records"""
    BloodGroup = apps.get_model("accounts", "BloodGroup")

    # Create BloodGroup records
    BloodGroup.objects.create(name="A+")
    BloodGroup.objects.create(name="A-")
    BloodGroup.objects.create(name="B+")
    BloodGroup.objects.create(name="B-")
    BloodGroup.objects.create(name="AB+")
    BloodGroup.objects.create(name="AB-")
    BloodGroup.objects.create(name="O+")
    BloodGroup.objects.create(name="O-")


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0015_bloodgroup_and_more"),
    ]

    operations = [
        migrations.RunPython(create_blood_groups, migrations.RunPython.noop),
    ]
