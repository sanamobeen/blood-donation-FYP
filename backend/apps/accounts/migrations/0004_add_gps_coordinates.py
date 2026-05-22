# Generated manually to add GPS coordinates to UserProfile

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_alter_customuser_phone'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='latitude',
            field=models.DecimalField(
                blank=True,
                decimal_places=6,
                help_text='GPS latitude coordinate',
                max_digits=9,
                null=True,
                verbose_name='Latitude'
            ),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='longitude',
            field=models.DecimalField(
                blank=True,
                decimal_places=6,
                help_text='GPS longitude coordinate',
                max_digits=9,
                null=True,
                verbose_name='Longitude'
            ),
        ),
    ]
