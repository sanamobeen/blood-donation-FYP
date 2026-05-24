"""
Restore the blood_requests and donations migrations that were removed
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blooddonation.settings')
django.setup()

from django.db import connection

def restore_migrations():
    """Restore migrations that were removed by fix_migrations.py"""
    migrations_to_restore = [
        ('blood_requests', '0002_update_user_foreign_key'),
        ('donations', '0002_update_donor_foreign_key'),
    ]

    with connection.cursor() as cursor:
        for app, name in migrations_to_restore:
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
                print(f"Restored: {app}.{name}")
            else:
                print(f"Already exists: {app}.{name}")

    print("\nMigrations restored! Now run: python manage.py migrate")

if __name__ == '__main__':
    restore_migrations()
