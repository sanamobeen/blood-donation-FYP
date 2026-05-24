"""
Fix inconsistent migration history by removing the problematic blood_requests migration record
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blooddonation.settings')
django.setup()

from django.db import connection

def fix_migrations():
    """Remove the problematic migration record"""
    with connection.cursor() as cursor:
        # Check current state
        cursor.execute("SELECT app, name FROM django_migrations WHERE app='blood_requests' OR app='accounts' ORDER BY app, name")
        print("Current migration state:")
        for row in cursor.fetchall():
            print(f"  {row[0]}.{row[1]}")

        # Remove the problematic migration
        cursor.execute("DELETE FROM django_migrations WHERE app='blood_requests' AND name='0002_update_user_foreign_key'")
        print(f"\nRemoved blood_requests.0002_update_user_foreign_key")

        # Also remove donations.0002 if it exists (same issue)
        cursor.execute("DELETE FROM django_migrations WHERE app='donations' AND name='0002_update_donor_foreign_key'")
        print(f"Removed donations.0002_update_donor_foreign_key (if existed)")

    print("\nFixed! Now run: python manage.py migrate")

if __name__ == '__main__':
    fix_migrations()
