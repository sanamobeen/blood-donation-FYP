"""
Clean up migration mess by removing obsolete migrations that reference non-existent models
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blooddonation.settings')
django.setup()

from django.db import connection

def clean_migrations():
    """Remove obsolete migrations and fix the chain"""
    # Remove fake migrations from database
    migrations_to_remove = [
        ('accounts', '0012_myuser_role'),
        ('accounts', '0013_alter_myuser_email_myuser_unique_email_role'),
        ('accounts', '0014_separate_donor_patient_tables'),
        ('accounts', '0015_unified_user_migration'),
        ('accounts', '0017_merge_20260522_1635'),  # The failed merge
    ]

    with connection.cursor() as cursor:
        for app, name in migrations_to_remove:
            cursor.execute(
                "DELETE FROM django_migrations WHERE app=%s AND name=%s",
                [app, name]
            )
            print(f"Removed: {app}.{name}")

    print("\nCleaned up! The migration chain is now fixed.")
    print("Next: Delete the obsolete migration files and update 0016 dependency")

if __name__ == '__main__':
    clean_migrations()
