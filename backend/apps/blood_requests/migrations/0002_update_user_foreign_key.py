from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ('blood_requests', '0001_initial'),
        ('accounts', '0004_add_gps_coordinates'),
    ]

    operations = [
        # Add new created_by ForeignKey to CustomUser model
        migrations.AddField(
            model_name='bloodrequest',
            name='created_by',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='blood_requests',
                to='accounts.customuser',
                null=True,
                blank=True,
                help_text="User who created the request"
            ),
        ),
    ]
