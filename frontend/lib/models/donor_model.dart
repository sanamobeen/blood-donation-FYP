import 'package:geolocator/geolocator.dart';

class Donor {
  final String id;
  final String name;
  final String email;
  final String bloodGroup;
  final String province;
  final String district;
  final String localLevel;
  final String phone;
  final bool isAvailable;
  final String gender;
  final double? distance;
  final double latitude;
  final double longitude;
  final DateTime? lastDonationDate;
  final int? totalDonations;

  Donor({
    required this.id,
    required this.name,
    required this.email,
    required this.bloodGroup,
    required this.province,
    required this.district,
    required this.localLevel,
    required this.phone,
    required this.isAvailable,
    required this.gender,
    this.distance,
    required this.latitude,
    required this.longitude,
    this.lastDonationDate,
    this.totalDonations,
  });

  // Factory constructor for JSON parsing from API
  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id']?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      bloodGroup: json['blood_group'] ?? 'O+',
      province: json['province'] ?? 'Unknown',
      district: json['district'] ?? 'Unknown',
      localLevel: json['local_level'] ?? 'Unknown',
      phone: json['phone'] ?? 'N/A',
      isAvailable: json['is_available'] ?? true,
      gender: json['gender'] ?? 'Other',
      distance: json['distance_km']?.toDouble(),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'])
          : null,
      totalDonations: json['total_donations'],
    );
  }

  // Calculate distance from user location (fallback if not provided by API)
  double calculateDistanceFrom(double userLat, double userLng) {
    if (distance != null) return distance!;

    final distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      latitude,
      longitude,
    );

    return distanceInMeters / 1000; // Convert to kilometers
  }
}
