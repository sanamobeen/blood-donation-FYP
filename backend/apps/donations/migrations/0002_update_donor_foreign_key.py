from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ('donations', '0001_initial'),
        ('accounts', '0003_alter_customuser_phone'),
    ]

    operations = [
        # Add new donor ForeignKey to User model (if not exists)
        migrations.AddField(
            model_name='donation',
            name='donor',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='donations',
                to='accounts.customuser',
                null=True,
                blank=True,
                help_text="User who made the donation (must have 'donor' role)"
            ),
        ),
    ]
