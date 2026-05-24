# Generated migration for is_verified field

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0004_add_gps_coordinates'),
    ]

    operations = [
        migrations.AddField(
            model_name='customuser',
            name='is_verified',
            field=models.BooleanField(default=False, help_text='Designates whether the user\'s email has been verified', verbose_name='Email Verified'),
        ),
    ]
