# Generated migration to change token to 6-digit code

from django.db import migrations, models
import random


def generate_code():
    """Generate a random 6-digit code"""
    return f"{random.randint(100000, 999999)}"


def generate_codes_for_existing(apps, schema_editor):
    """Generate 6-digit codes for existing records"""
    EmailVerification = apps.get_model('accounts', 'EmailVerification')

    for verification in EmailVerification.objects.all():
        if not verification.code or verification.code == '':
            # Generate unique code
            while True:
                code = generate_code()
                if not EmailVerification.objects.filter(code=code).exists():
                    verification.code = code
                    verification.save()
                    break


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0016_add_is_verified_field'),
    ]

    operations = [
        # First, add the code field as nullable and non-unique
        migrations.AddField(
            model_name='emailverification',
            name='code',
            field=models.CharField(max_length=6, editable=False, null=True, help_text='6-digit verification code for email verification', verbose_name='Verification Code'),
        ),
        # Generate codes for existing records
        migrations.RunPython(generate_codes_for_existing, migrations.RunPython.noop),
        # Now make it unique and not null
        migrations.AlterField(
            model_name='emailverification',
            name='code',
            field=models.CharField(max_length=6, editable=False, unique=True, help_text='6-digit verification code for email verification', verbose_name='Verification Code'),
        ),
        # Remove the old token field
        migrations.RemoveField(
            model_name='emailverification',
            name='token',
        ),
        # Add index for code
        migrations.AddIndex(
            model_name='emailverification',
            index=models.Index(fields=['code'], name='accounts_email_code_idx'),
        ),
    ]
