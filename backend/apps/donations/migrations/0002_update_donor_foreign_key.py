from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ('donations', '0001_initial'),
        ('accounts', '0015_unified_user_migration'),
    ]

    operations = [
        # Remove old donor_id integer field
        migrations.RemoveField(
            model_name='donation',
            name='donor_id',
        ),
        # Add new donor ForeignKey to User model
        migrations.AddField(
            model_name='donation',
            name='donor',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='donations',
                to='accounts.user',
                null=True,
                blank=True,
                help_text="User who made the donation (must have 'donor' role)"
            ),
        ),
    ]
