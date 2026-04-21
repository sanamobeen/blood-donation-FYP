import 'package:geolocator/geolocator.dart';

class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String province;
  final String district;
  final String localLevel;
  final String phone;
  final String? email;
  final DateTime lastDonationDate;
  final int totalDonations;
  final bool isAvailable;
  final String gender;
  final double? distance;

  // GPS coordinates
  final double latitude;
  final double longitude;

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.province,
    required this.district,
    required this.localLevel,
    required this.phone,
    this.email,
    required this.lastDonationDate,
    required this.totalDonations,
    required this.isAvailable,
    required this.gender,
    this.distance,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor for JSON parsing (future API use)
  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'].toString(),
      name: json['user']['full_name'] ?? json['name'] ?? 'Unknown',
      bloodGroup: json['blood_group'] ?? 'O+',
      province: json['user']['city'] ?? json['province'] ?? 'Unknown',
      district: json['district'] ?? 'Unknown',
      localLevel: json['local_level'] ?? 'Unknown',
      phone: json['user']['phone'] ?? json['phone'] ?? 'N/A',
      email: json['user']['email'],
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'])
          : DateTime.now(),
      totalDonations: json['total_donations'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      gender: json['user']['gender'] ?? 'Other',
      distance: json['distance']?.toDouble(),
      latitude: json['latitude'] ?? 27.7172,
      longitude: json['longitude'] ?? 85.3240,
    );
  }

  // Calculate distance from user location
  double calculateDistanceFrom(double userLat, double userLng) {
    final distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      latitude,
      longitude,
    );

    return distanceInMeters / 1000; // Convert to kilometers
  }

  // Calculate age from date of birth (optional field)
  int? calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Check if donor is eligible to donate (3 months since last donation)
  bool get isEligibleToDonate {
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return lastDonationDate.isBefore(threeMonthsAgo);
  }
}
