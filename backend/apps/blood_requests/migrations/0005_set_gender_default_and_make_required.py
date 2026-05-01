# Generated migration to handle gender field requirement

from django.db import migrations, models


def set_gender_default(apps, schema_editor):
    """Set default gender for existing NULL values"""
    BloodRequest = apps.get_model("blood_requests", "BloodRequest")
    # Update all NULL values to "Other"
    BloodRequest.objects.filter(gender__isnull=True).update(gender="Other")


class Migration(migrations.Migration):

    dependencies = [
        ("blood_requests", "0004_alter_bloodrequest_district_and_more"),
    ]

    operations = [
        # First, set default values for existing NULL records
        migrations.RunPython(set_gender_default, migrations.RunPython.noop),
        # Then make the field required
        migrations.AlterField(
            model_name="bloodrequest",
            name="gender",
            field=models.CharField(
                choices=[("Male", "Male"), ("Female", "Female"), ("Other", "Other")],
                max_length=10,
            ),
        ),
    ]
