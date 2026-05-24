"""
Fake apply obsolete migrations 0012-0015 to fix migration chain
These migrations are for old models (MyUser) that are no longer used
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blooddonation.settings')
django.setup()

from django.db import connection

def fake_migrations():
    """Fake apply migrations 0012-0015"""
    migrations_to_fake = [
        ('accounts', '0012_myuser_role'),
        ('accounts', '0013_alter_myuser_email_myuser_unique_email_role'),
        ('accounts', '0014_separate_donor_patient_tables'),
        ('accounts', '0015_unified_user_migration'),
    ]

    with connection.cursor() as cursor:
        for app, name in migrations_to_fake:
            # Check if already exists
            cursor.execute(
                "SELECT COUNT(*) FROM django_migrations WHERE app=%s AND name=%s",
                [app, name]
            )
            if cursor.fetchone()[0] == 0:
                cursor.execute(
                    "INSERT INTO django_migrations (app, name, applied) VALUES (%s, %s, NOW())",
                    [app, name]
                )
                print(f"Faked: {app}.{name}")
            else:
                print(f"Already exists: {app}.{name}")

    print("\nAll migrations faked! Now run: python manage.py migrate")

if __name__ == '__main__':
    fake_migrations()
