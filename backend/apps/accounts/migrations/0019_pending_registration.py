# Generated migration for PendingRegistration model

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0018_fix_code_field'),
    ]

    operations = [
        migrations.CreateModel(
            name='PendingRegistration',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('email', models.EmailField(help_text='Email address for pending registration', max_length=254, unique=True, verbose_name='Email Address')),
                ('password', models.CharField(help_text='Hashed password for the pending registration', max_length=128, verbose_name='Password')),
                ('full_name', models.CharField(blank=True, help_text="User's full name", max_length=150, verbose_name='Full Name')),
                ('phone', models.CharField(blank=True, help_text='Contact phone number', max_length=15, null=True, verbose_name='Phone Number')),
                ('verification_code', models.CharField(help_text='6-digit email verification code', max_length=6, unique=True, verbose_name='Verification Code')),
                ('created_at', models.DateTimeField(auto_now_add=True, help_text='Pending registration creation timestamp', verbose_name='Created At')),
                ('expires_at', models.DateTimeField(help_text='When this pending registration expires', verbose_name='Expires At')),
                ('is_verified', models.BooleanField(default=False, help_text='Whether the email has been verified', verbose_name='Verified')),
            ],
            options={
                'verbose_name': 'Pending Registration',
                'verbose_name_plural': 'Pending Registrations',
                'ordering': ['-created_at'],
                'indexes': [
                    models.Index(fields=['email'], name='accounts_pendin_email_idx'),
                    models.Index(fields=['verification_code'], name='accounts_pendin_code_idx'),
                    models.Index(fields=['is_verified', 'expires_at'], name='accounts_pendin_ver_idx'),
                ],
            },
        ),
    ]
