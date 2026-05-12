# Generated migration for unified user model with multiple roles

from django.db import migrations, models
import django.db.models.deletion
import uuid


def migrate_existing_users(apps, schema_editor):
    """
    Migrate existing data from MyUser, Donor, and Patient tables to new User model.
    If same email exists in multiple tables, merge into single User with multiple roles.
    """
    # Get models
    OldMyUser = apps.get_model('accounts', 'MyUser')
    OldDonor = apps.get_model('accounts', 'Donor')
    OldPatient = apps.get_model('accounts', 'Patient')
    NewUser = apps.get_model('accounts', 'User')
    DonorProfile = apps.get_model('accounts', 'DonorProfile')

    # Track migrated emails to avoid duplicates
    migrated_emails = {}
    # Structure: {email: {'user': NewUser instance, 'roles': set(), 'donor_data': {}, 'patient_data': {}}}

    # Step 1: Process MyUser records
    print("Migrating MyUser records...")
    for old_user in OldMyUser.objects.all():
        email = old_user.email.lower().strip()

        if email not in migrated_emails:
            migrated_emails[email] = {
                'user': None,
                'roles': set(),
                'donor_data': {},
                'patient_data': {}
            }

        # Add role
        migrated_emails[email]['roles'].add(old_user.role)

        # Store data based on role
        if old_user.role == 'donor':
            migrated_emails[email]['donor_data'] = {
                'blood_group': old_user.blood_group,
                'is_available': True,
                'last_donation_date': None,
                'total_donations': 0,
            }
        elif old_user.role == 'patient':
            migrated_emails[email]['patient_data'] = {}

        # Store basic user data (use first occurrence)
        if not migrated_emails[email].get('basic_data'):
            migrated_emails[email]['basic_data'] = {
                'email': email,
                'phone': old_user.phone or None,
                'password': old_user.password,  # Already hashed
                'full_name': old_user.full_name or '',
                'gender': old_user.gender,
                'date_of_birth': old_user.date_of_birth,
                'province': old_user.province,
                'district': old_user.district,
                'local_level': old_user.local_level,
                'is_phone_verified': True,  # Assume verified for existing users
                'is_active': old_user.is_active,
                'is_staff': old_user.is_staff,
            }

    # Step 2: Process Donor records (separate table)
    print("Migrating Donor records...")
    for old_donor in OldDonor.objects.all():
        email = old_donor.email.lower().strip()

        if email not in migrated_emails:
            migrated_emails[email] = {
                'user': None,
                'roles': set(),
                'donor_data': {},
                'patient_data': {},
                'basic_data': {}
            }

        # Add donor role
        migrated_emails[email]['roles'].add('donor')

        # Store donor-specific data
        migrated_emails[email]['donor_data'] = {
            'blood_group': old_donor.blood_group,
            'is_available': old_donor.is_available,
            'last_donation_date': old_donor.last_donation_date,
            'total_donations': old_donor.total_donations,
        }

        # Store basic data if not already present
        if not migrated_emails[email].get('basic_data'):
            migrated_emails[email]['basic_data'] = {
                'email': email,
                'phone': old_donor.phone or None,
                'password': old_donor.password,
                'full_name': old_donor.full_name or '',
                'gender': old_donor.gender,
                'date_of_birth': old_donor.date_of_birth,
                'province': old_donor.province,
                'district': old_donor.district,
                'local_level': old_donor.local_level,
                'is_phone_verified': True,
                'is_active': old_donor.is_active,
                'is_staff': old_donor.is_staff,
            }

    # Step 3: Process Patient records (separate table)
    print("Migrating Patient records...")
    for old_patient in OldPatient.objects.all():
        email = old_patient.email.lower().strip()

        if email not in migrated_emails:
            migrated_emails[email] = {
                'user': None,
                'roles': set(),
                'donor_data': {},
                'patient_data': {},
                'basic_data': {}
            }

        # Add patient role
        migrated_emails[email]['roles'].add('patient')

        # Store basic data if not already present
        if not migrated_emails[email].get('basic_data'):
            migrated_emails[email]['basic_data'] = {
                'email': email,
                'phone': old_patient.phone or None,
                'password': old_patient.password,
                'full_name': old_patient.full_name or '',
                'gender': old_patient.gender,
                'date_of_birth': old_patient.date_of_birth,
                'province': old_patient.province,
                'district': old_patient.district,
                'local_level': old_patient.local_level,
                'is_phone_verified': True,
                'is_active': old_patient.is_active,
                'is_staff': old_patient.is_staff,
            }

    # Step 4: Create new User records
    print("Creating new User records...")
    for email, data in migrated_emails.items():
        basic_data = data['basic_data']
        roles = list(data['roles'])

        # Handle phone number - check for duplicates
        phone = basic_data.get('phone')
        if phone:
            # Check if phone is already used by a previously created user
            if NewUser.objects.filter(phone=phone).exists():
                print(f"Warning: Duplicate phone {phone} for {email}, setting to None")
                phone = None

        # Create User
        new_user = NewUser.objects.create(
            email=basic_data['email'],
            phone=phone,
            password=basic_data['password'],  # Already hashed
            full_name=basic_data.get('full_name', ''),
            gender=basic_data.get('gender'),
            date_of_birth=basic_data.get('date_of_birth'),
            province=basic_data.get('province'),
            district=basic_data.get('district'),
            local_level=basic_data.get('local_level'),
            roles=roles,
            is_phone_verified=basic_data.get('is_phone_verified', True),
            is_active=basic_data.get('is_active', True),
            is_staff=basic_data.get('is_staff', False),
        )

        # Create DonorProfile if user has donor role
        if 'donor' in roles and data.get('donor_data'):
            donor_data = data['donor_data']
            blood_group = donor_data.get('blood_group') or 'O+'  # Handle None or empty
            DonorProfile.objects.create(
                user=new_user,
                blood_group=blood_group,
                is_available=donor_data.get('is_available', True),
                last_donation_date=donor_data.get('last_donation_date'),
                total_donations=donor_data.get('total_donations', 0),
            )

        print(f"Created user: {email} with roles: {roles}")

    print(f"Migration complete! Migrated {len(migrated_emails)} users.")


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0014_separate_donor_patient_tables'),
    ]

    operations = [
        # Create new User model
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('password', models.CharField(max_length=128, verbose_name='Password')),
                ('last_login', models.DateTimeField(blank=True, null=True)),
                ('is_superuser', models.BooleanField(default=False)),
                ('email', models.EmailField(help_text="User's email address (unique across all users)", max_length=254, unique=True, verbose_name='Email Address')),
                ('phone', models.CharField(blank=True, help_text='Contact phone number (unique, used for OTP verification)', max_length=15, null=True, unique=True, verbose_name='Phone Number')),
                ('full_name', models.CharField(blank=True, default='', help_text="User's complete name", max_length=100, verbose_name='Full Name')),
                ('gender', models.CharField(blank=True, choices=[('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')], help_text="User's gender (optional for patients, required for donors)", max_length=10, null=True, verbose_name='Gender')),
                ('date_of_birth', models.DateField(blank=True, help_text="User's date of birth (required for age validation)", null=True, verbose_name='Date of Birth')),
                ('province', models.CharField(blank=True, choices=[('Punjab', 'Punjab'), ('Sindh', 'Sindh'), ('Khyber Pakhtunkhwa', 'Khyber Pakhtunkhwa'), ('Balochistan', 'Balochistan'), ('Islamabad Capital Territory', 'Islamabad Capital Territory'), ('Gilgit-Baltistan', 'Gilgit-Baltistan'), ('Azad Jammu and Kashmir', 'Azad Jammu and Kashmir')], help_text="User's province", max_length=100, null=True, verbose_name='Province')),
                ('district', models.CharField(blank=True, choices=[], help_text="User's district within province", max_length=100, null=True, verbose_name='District')),
                ('local_level', models.CharField(blank=True, help_text='Specific area or locality', max_length=200, null=True, verbose_name='Local Level')),
                ('roles', models.JSONField(default=list, help_text="Array of roles: ['donor', 'patient']. A user can have multiple roles.", verbose_name='Roles')),
                ('is_phone_verified', models.BooleanField(default=False, help_text="Whether the user's phone number has been verified via OTP", verbose_name='Phone Verified')),
                ('is_active', models.BooleanField(default=True, help_text='Designates whether this user should be treated as active', verbose_name='Active')),
                ('created_at', models.DateTimeField(auto_now_add=True, help_text='Account creation timestamp', verbose_name='Created At')),
                ('updated_at', models.DateTimeField(auto_now=True, help_text='Last update timestamp', verbose_name='Updated At')),
                ('is_staff', models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site', verbose_name='Staff Status')),
                ('groups', models.ManyToManyField(blank=True, help_text='The groups this user belongs to.', related_name='user_set_new', related_query_name='user', to='auth.Group')),
                ('user_permissions', models.ManyToManyField(blank=True, help_text='Specific permissions for this user.', related_name='user_set_new', related_query_name='user', to='auth.Permission')),
            ],
            options={
                'verbose_name': 'User',
                'verbose_name_plural': 'Users',
                'ordering': ['-created_at'],
                'indexes': [
                    models.Index(fields=['email'], name='accounts_user_email_idx'),
                    models.Index(fields=['phone'], name='accounts_user_phone_idx'),
                    # Note: MySQL doesn't support generic JSON indexes, so we removed the roles index
                    models.Index(fields=['is_active'], name='accounts_user_active_idx'),
                    models.Index(fields=['created_at'], name='accounts_user_created_idx'),
                ],
            },
        ),

        # Create DonorProfile model
        migrations.CreateModel(
            name='DonorProfile',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('blood_group', models.CharField(choices=[('A+', 'A+'), ('A-', 'A-'), ('B+', 'B+'), ('B-', 'B-'), ('AB+', 'AB+'), ('AB-', 'AB-'), ('O+', 'O+'), ('O-', 'O-')], help_text="Donor's blood group", max_length=3, verbose_name='Blood Group')),
                ('is_available', models.BooleanField(default=True, help_text='Whether the donor is currently available for blood donation', verbose_name='Available for Donation')),
                ('last_donation_date', models.DateField(blank=True, help_text='Date of the most recent blood donation', null=True, verbose_name='Last Donation Date')),
                ('total_donations', models.IntegerField(default=0, help_text='Total number of blood donations made', verbose_name='Total Donations')),
                ('created_at', models.DateTimeField(auto_now_add=True, help_text='Profile creation timestamp', verbose_name='Created At')),
                ('updated_at', models.DateTimeField(auto_now=True, help_text='Last update timestamp', verbose_name='Updated At')),
                ('user', models.OneToOneField(help_text="Reference to the user account (must have 'donor' role)", on_delete=django.db.models.deletion.CASCADE, related_name='donor_profile', to='accounts.user')),
            ],
            options={
                'verbose_name': 'Donor Profile',
                'verbose_name_plural': 'Donor Profiles',
                'ordering': ['-created_at'],
                'indexes': [
                    models.Index(fields=['user'], name='accounts_donor_profile_user_idx'),
                    models.Index(fields=['blood_group'], name='accounts_donor_profile_bg_idx'),
                    models.Index(fields=['is_available'], name='accounts_donor_profile_avail_idx'),
                ],
            },
        ),

        # Create OTPVerification model
        migrations.CreateModel(
            name='OTPVerification',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('phone', models.CharField(help_text='Phone number for OTP verification', max_length=15, verbose_name='Phone Number')),
                ('otp', models.CharField(help_text='6-digit one-time password', max_length=6, verbose_name='OTP Code')),
                ('purpose', models.CharField(choices=[('registration', 'Registration'), ('login', 'Login'), ('password_reset', 'Password Reset')], help_text='Purpose of OTP verification', max_length=20, verbose_name='Purpose')),
                ('created_at', models.DateTimeField(auto_now_add=True, help_text='OTP creation timestamp', verbose_name='Created At')),
                ('is_used', models.BooleanField(default=False, help_text='Whether the OTP has been used', verbose_name='Used')),
                ('attempts', models.IntegerField(default=0, help_text='Number of verification attempts', verbose_name='Attempts')),
            ],
            options={
                'verbose_name': 'OTP Verification',
                'verbose_name_plural': 'OTP Verifications',
                'ordering': ['-created_at'],
                'indexes': [
                    models.Index(fields=['phone', 'purpose', 'is_used'], name='accounts_otp_phone_purpose_used_idx'),
                    models.Index(fields=['created_at'], name='accounts_otp_created_idx'),
                ],
            },
        ),

        # Run data migration
        migrations.RunPython(migrate_existing_users, migrations.RunPython.noop),

        # NOTE: We are NOT deleting old models yet
        # Keep MyUser, Donor, Patient for at least 1 week for rollback safety
    ]
