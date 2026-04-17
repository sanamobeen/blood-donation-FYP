# accounts/serializers.py
from rest_framework import serializers
from .models import MyUser, Donor
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.hashers import make_password


# USER SERIALIZER
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyUser
        fields = ['id', 'full_name', 'email', 'phone', 'city', 'gender', 'date_of_birth', 'role', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


# REGISTER SERIALIZER
class RegisterSerializer(serializers.ModelSerializer):
    # Frontend sends 'province' but we store it as 'city'
    province = serializers.CharField(write_only=True, required=True, error_messages={"required": "Province is required"})
    blood_group = serializers.CharField(write_only=True, required=False)
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = MyUser
        fields = [
            'full_name',
            'email',
            'phone',
            'gender',
            'province',  # Will be mapped to city
            'date_of_birth',
            'role',
            'blood_group',  # Will be used to create donor profile
            'password',
            'confirm_password',
        ]

    def validate(self, attrs):
        # Map province to city
        if 'province' in attrs:
            attrs['city'] = attrs.pop('province')

        # Validate password confirmation
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})

        # Validate province is not empty
        if 'city' in attrs and not attrs['city'].strip():
            raise serializers.ValidationError({"province": "Province cannot be empty"})

        # Validate gender is not empty
        if 'gender' in attrs and not attrs['gender'].strip():
            raise serializers.ValidationError({"gender": "Gender cannot be empty"})

        # Validate email format
        if 'email' in attrs:
            email = attrs['email'].strip().lower()
            if MyUser.objects.filter(email=email).exists():
                raise serializers.ValidationError({"email": "A user with this email already exists"})
            attrs['email'] = email

        # Validate blood_group if provided
        if 'blood_group' in attrs and attrs['blood_group']:
            valid_blood_groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
            if attrs['blood_group'] not in valid_blood_groups:
                raise serializers.ValidationError({"blood_group": "Invalid blood group"})

        return attrs

    def create(self, validated_data):
        blood_group = validated_data.pop('blood_group', None)
        validated_data.pop('confirm_password')  # Remove confirm_password before creating user

        # Set default role if not provided
        if 'role' not in validated_data or not validated_data['role']:
            validated_data['role'] = 'patient'

        # Create user with password
        user = MyUser(**validated_data)
        password = validated_data.pop('password')
        user.set_password(password)
        user.save()

        # Create donor profile if blood_group is provided
        if blood_group:
            Donor.objects.create(
                user=user,
                blood_group=blood_group,
                is_available=True
            )

        return user


# LOGIN SERIALIZER
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True, write_only=True)

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        if email and password:
            user = authenticate(username=email, password=password)
            if not user:
                raise serializers.ValidationError('Invalid credentials')
            if not user.is_active:
                raise serializers.ValidationError('User account is disabled')
            attrs['user'] = user
            return attrs
        else:
            raise serializers.ValidationError('Must include email and password')


# DONOR SERIALIZER
class DonorSerializer(serializers.ModelSerializer):
    # Include user information as individual fields instead of nested object
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)
    phone = serializers.CharField(source='user.phone', read_only=True)
    city = serializers.CharField(source='user.city', read_only=True)
    gender = serializers.CharField(source='user.gender', read_only=True)

    class Meta:
        model = Donor
        fields = [
            'id',
            'email',
            'first_name',
            'last_name',
            'phone',
            'city',
            'gender',
            'blood_group',
            'is_available',
            'last_donation_date',
            'total_donations',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at', 'total_donations']


# DONOR REGISTRATION SERIALIZER
class DonorRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Donor
        fields = ['blood_group', 'is_available']

    def create(self, validated_data):
        user = self.context['request'].user
        if Donor.objects.filter(user=user).exists():
            raise serializers.ValidationError("User is already registered as a donor")
        validated_data['user'] = user
        return super().create(validated_data)
