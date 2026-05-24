# Generated migration to fix code field

from django.db import migrations, models
import random


def generate_code():
    """Generate a random 6-digit code"""
    return f"{random.randint(100000, 999999)}"


def generate_codes_for_existing(apps, schema_editor):
    """Generate 6-digit codes for existing records that don't have one"""
    EmailVerification = apps.get_model('accounts', 'EmailVerification')

    for verification in EmailVerification.objects.filter(code__isnull=True) | EmailVerification.objects.filter(code=''):
        # Generate unique code
        while True:
            code = generate_code()
            if not EmailVerification.objects.filter(code=code).exists():
                verification.code = code
                verification.save(update_fields=['code'])
                break


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0017_change_token_to_code'),
    ]

    operations = [
        # Generate codes for existing records
        migrations.RunPython(generate_codes_for_existing, migrations.RunPython.noop),
        # Make code field not null and unique
        migrations.AlterField(
            model_name='emailverification',
            name='code',
            field=models.CharField(max_length=6, editable=False, unique=True, help_text='6-digit verification code for email verification', verbose_name='Verification Code'),
        ),
        # Add index for code
        migrations.AddIndex(
            model_name='emailverification',
            index=models.Index(fields=['code'], name='accounts_email_code_idx'),
        ),
    ]
