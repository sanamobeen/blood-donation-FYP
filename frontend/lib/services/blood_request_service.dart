import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/blood_request_model.dart';

/// Blood Request Service
/// Handles all blood request related API operations
class BloodRequestService {

  /// Get authorization header with JWT token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create a new blood request
  static Future<BloodRequestResult> createBloodRequest({
    required String patientName,
    required String emergencyContact,
    required int bloodGroup,
    required int gender,
    required int province,
    required int district,
    required int localLevel,
    required int unitsRequired,
    required String requiredDate,
    required String requiredTime,
    String? caseDescription,
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'patient_name': patientName.trim(),
        'emergency_contact': emergencyContact.trim(),
        'blood_group': bloodGroup,
        'gender': gender,
        'province': province,
        'district': district,
        'local_level': localLevel,
        'units_required': unitsRequired,
        'required_date': requiredDate,
        'required_time': requiredTime,
        if (caseDescription != null && caseDescription.trim().isNotEmpty)
          'case': caseDescription.trim(),
      };

      if (kDebugMode) {
        print('Creating blood request with data: $requestData');
      }

      // Make API call
      final response = await http.post(
        Uri.parse(ApiConfig.bloodRequestCreateEndpoint),
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestData),
      ).timeout(
        ApiConfig.connectTimeout,
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Handle successful creation
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final bloodRequest = BloodRequest.fromJson(responseData['blood_request']);

        return BloodRequestResult.success(
          bloodRequest: bloodRequest,
          message: responseData['message'] ?? 'Blood request created successfully',
        );
      }

      // Handle error response
      final errorData = jsonDecode(response.body);
      String errorMessage = 'Failed to create blood request';

      if (errorData.containsKey('detail')) {
        errorMessage = errorData['detail'];
      } else if (errorData.containsKey('message')) {
        errorMessage = errorData['message'];
      } else if (errorData.containsKey('error')) {
        errorMessage = errorData['error'];
      }

      return BloodRequestResult.failure(errorMessage);

    } catch (e) {
      if (kDebugMode) {
        print('Create blood request error: $e');
      }

      String errorMessage = 'Failed to create blood request';
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Connection') || e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('No authentication token')) {
        errorMessage = 'Please login first to create a blood request.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Please check if backend is running.';
      }

      return BloodRequestResult.failure(errorMessage);
    }
  }

  /// Get all blood requests
  static Future<BloodRequestListResult> getBloodRequests({
    int? bloodGroup,
    String? status,
    int? province,
    int? district,
    int? gender,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (bloodGroup != null) queryParams['blood_group'] = bloodGroup.toString();
      if (status != null) queryParams['status'] = status;
      if (province != null) queryParams['province'] = province.toString();
      if (district != null) queryParams['district'] = district.toString();
      if (gender != null) queryParams['gender'] = gender.toString();

      final uri = Uri.parse(ApiConfig.bloodRequestListEndpoint)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final bloodRequests = jsonData
            .map((item) => BloodRequest.fromJson(item))
            .toList();

        return BloodRequestListResult.success(bloodRequests);
      }

      return BloodRequestListResult.failure('Failed to load blood requests');

    } catch (e) {
      if (kDebugMode) {
        print('Get blood requests error: $e');
      }
      return BloodRequestListResult.failure('Network error. Please try again.');
    }
  }

  /// Get current user's blood requests
  static Future<BloodRequestListResult> getMyBloodRequests() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.bloodRequestMyRequestsEndpoint),
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final bloodRequests = jsonData
            .map((item) => BloodRequest.fromJson(item))
            .toList();

        return BloodRequestListResult.success(bloodRequests);
      }

      return BloodRequestListResult.failure('Failed to load your blood requests');

    } catch (e) {
      if (kDebugMode) {
        print('Get my blood requests error: $e');
      }
      return BloodRequestListResult.failure('Network error. Please try again.');
    }
  }

  /// Get blood request by ID
  static Future<BloodRequestResult> getBloodRequestById(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.bloodRequestDetailEndpoint(id)),
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bloodRequest = BloodRequest.fromJson(jsonData);

        return BloodRequestResult.success(bloodRequest: bloodRequest);
      }

      if (response.statusCode == 404) {
        return BloodRequestResult.failure('Blood request not found');
      }

      return BloodRequestResult.failure('Failed to load blood request');

    } catch (e) {
      if (kDebugMode) {
        print('Get blood request error: $e');
      }
      return BloodRequestResult.failure('Network error. Please try again.');
    }
  }

  /// Update blood request
  static Future<BloodRequestResult> updateBloodRequest({
    required int id,
    required String patientName,
    required String emergencyContact,
    required int bloodGroup,
    required int gender,
    required int province,
    required int district,
    required int localLevel,
    required int unitsRequired,
    required String requiredDate,
    required String requiredTime,
    String? caseDescription,
  }) async {
    try {
      final requestData = {
        'patient_name': patientName.trim(),
        'emergency_contact': emergencyContact.trim(),
        'blood_group': bloodGroup,
        'gender': gender,
        'province': province,
        'district': district,
        'local_level': localLevel,
        'units_required': unitsRequired,
        'required_date': requiredDate,
        'required_time': requiredTime,
        if (caseDescription != null && caseDescription.trim().isNotEmpty)
          'case': caseDescription.trim(),
      };

      final response = await http.put(
        Uri.parse(ApiConfig.bloodRequestDetailEndpoint(id)),
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestData),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final bloodRequest = BloodRequest.fromJson(responseData['blood_request']);

        return BloodRequestResult.success(
          bloodRequest: bloodRequest,
          message: 'Blood request updated successfully',
        );
      }

      return BloodRequestResult.failure('Failed to update blood request');

    } catch (e) {
      if (kDebugMode) {
        print('Update blood request error: $e');
      }
      return BloodRequestResult.failure('Network error. Please try again.');
    }
  }

  /// Delete blood request
  static Future<BloodRequestResult> deleteBloodRequest(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.bloodRequestDetailEndpoint(id)),
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 204) {
        return BloodRequestResult.success(
          message: 'Blood request deleted successfully',
        );
      }

      return BloodRequestResult.failure('Failed to delete blood request');

    } catch (e) {
      if (kDebugMode) {
        print('Delete blood request error: $e');
      }
      return BloodRequestResult.failure('Network error. Please try again.');
    }
  }

  /// Get provinces
  static Future<LocationResult> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.provincesEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final provinces = jsonData
            .map((item) => Province.fromJson(item))
            .toList();

        return LocationResult.success(provinces: provinces);
      }

      return LocationResult.failure('Failed to load provinces');

    } catch (e) {
      return LocationResult.failure('Network error. Please try again.');
    }
  }

  /// Get districts by province
  static Future<LocationResult> getDistricts(int? provinceId) async {
    try {
      final uri = Uri.parse(ApiConfig.districtsEndpoint);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final districts = jsonData
            .map((item) => District.fromJson(item))
            .toList();

        // Filter by province if provided
        if (provinceId != null) {
          districts.retainWhere((d) => d.province == provinceId);
        }

        return LocationResult.success(districts: districts);
      }

      return LocationResult.failure('Failed to load districts');

    } catch (e) {
      return LocationResult.failure('Network error. Please try again.');
    }
  }

  /// Get local levels by district
  static Future<LocationResult> getLocalLevels(int? districtId) async {
    try {
      final uri = Uri.parse(ApiConfig.localLevelsEndpoint);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final localLevels = jsonData
            .map((item) => LocalLevel.fromJson(item))
            .toList();

        // Filter by district if provided
        if (districtId != null) {
          localLevels.retainWhere((ll) => ll.district == districtId);
        }

        return LocationResult.success(localLevels: localLevels);
      }

      return LocationResult.failure('Failed to load local levels');

    } catch (e) {
      return LocationResult.failure('Network error. Please try again.');
    }
  }

  /// Get blood groups
  static Future<LocationResult> getBloodGroups() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.bloodGroupsEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final bloodGroups = jsonData
            .map((item) => BloodGroup.fromJson(item))
            .toList();

        return LocationResult.success(bloodGroups: bloodGroups);
      }

      return LocationResult.failure('Failed to load blood groups');

    } catch (e) {
      return LocationResult.failure('Network error. Please try again.');
    }
  }

  /// Get genders
  static Future<LocationResult> getGenders() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.gendersEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final genders = jsonData
            .map((item) => Gender.fromJson(item))
            .toList();

        return LocationResult.success(genders: genders);
      }

      return LocationResult.failure('Failed to load genders');

    } catch (e) {
      return LocationResult.failure('Network error. Please try again.');
    }
  }
}

/// Result class for single blood request operations
class BloodRequestResult {
  final bool success;
  final BloodRequest? bloodRequest;
  final String? message;

  BloodRequestResult._({
    required this.success,
    this.bloodRequest,
    this.message,
  });

  factory BloodRequestResult.success({
    BloodRequest? bloodRequest,
    String? message,
  }) {
    return BloodRequestResult._(
      success: true,
      bloodRequest: bloodRequest,
      message: message,
    );
  }

  factory BloodRequestResult.failure(String errorMessage) {
    return BloodRequestResult._(
      success: false,
      message: errorMessage,
    );
  }

  String get errorMessage => message ?? 'Unknown error occurred';
}

/// Result class for blood request list operations
class BloodRequestListResult {
  final bool success;
  final List<BloodRequest>? bloodRequests;
  final String? message;

  BloodRequestListResult._({
    required this.success,
    this.bloodRequests,
    this.message,
  });

  factory BloodRequestListResult.success(List<BloodRequest> bloodRequests) {
    return BloodRequestListResult._(
      success: true,
      bloodRequests: bloodRequests,
    );
  }

  factory BloodRequestListResult.failure(String errorMessage) {
    return BloodRequestListResult._(
      success: false,
      message: errorMessage,
    );
  }

  String get errorMessage => message ?? 'Unknown error occurred';
}

/// Result class for location data operations
class LocationResult {
  final bool success;
  final List<Province>? provinces;
  final List<District>? districts;
  final List<LocalLevel>? localLevels;
  final List<BloodGroup>? bloodGroups;
  final List<Gender>? genders;
  final String? message;

  LocationResult._({
    required this.success,
    this.provinces,
    this.districts,
    this.localLevels,
    this.bloodGroups,
    this.genders,
    this.message,
  });

  factory LocationResult.success({
    List<Province>? provinces,
    List<District>? districts,
    List<LocalLevel>? localLevels,
    List<BloodGroup>? bloodGroups,
    List<Gender>? genders,
  }) {
    return LocationResult._(
      success: true,
      provinces: provinces,
      districts: districts,
      localLevels: localLevels,
      bloodGroups: bloodGroups,
      genders: genders,
    );
  }

  factory LocationResult.failure(String errorMessage) {
    return LocationResult._(
      success: false,
      message: errorMessage,
    );
  }

  String get errorMessage => message ?? 'Unknown error occurred';
}
