import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/donor_model.dart';
import '../utils/mock_data.dart';

class DonorService {
  /// Fetch donors near a location within a radius
  static Future<DonorSearchResult> fetchDonorsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    String? bloodGroup,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius_km': radiusKm.toString(),
      };

      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        queryParams['blood_group'] = bloodGroup;
      }

      // Make the API request
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/accounts/donors/nearby/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(
        ApiConfig.connectTimeout,
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (kDebugMode) {
        print('Donor search response: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final donorsData = responseData['data']['donors'] as List;
          final donors = donorsData.map((json) => Donor.fromJson(json)).toList();

          return DonorSearchResult(
            success: true,
            donors: donors,
            count: donors.length,
            searchCenter: SearchCenter(
              latitude: responseData['data']['search_center']['latitude'],
              longitude: responseData['data']['search_center']['longitude'],
              radiusKm: responseData['data']['search_center']['radius_km'],
            ),
            filters: SearchFilters(
              bloodGroup: responseData['data']['filters']['blood_group'],
            ),
            message: responseData['message'] ?? 'Found donors',
          );
        }
      }

      return DonorSearchResult(
        success: false,
        donors: [],
        message: 'Failed to fetch donors',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Donor search error: $e');
      }

      String errorMessage = 'Failed to search donors';
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please check your connection.';
      } else if (e.toString().contains('Connection') || e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      return DonorSearchResult(
        success: false,
        donors: [],
        message: errorMessage,
      );
    }
  }

  /// Get available filter options
  static Future<FilterOptions?> getFilterOptions() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/accounts/donors/filters/');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return FilterOptions.fromJson(responseData['data']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Filter options error: $e');
      }
    }
    return null;
  }

  // Legacy methods for backward compatibility with find_donor.dart

  /// Fetch all donors (returns mock data for legacy support)
  static Future<List<Donor>> fetchDonors({
    String? bloodGroup,
    String? province,
    String? district,
    String? searchQuery,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return MockDonorData.getMockDonors();
  }

  /// Filter donors locally (legacy method)
  static List<Donor> filterDonors(
    List<Donor> donors, {
    String? bloodGroup,
    String? province,
    String? district,
    String? searchQuery,
  }) {
    List<Donor> filtered = List.from(donors);

    // Filter by blood group
    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      filtered = filtered.where((d) => d.bloodGroup == bloodGroup).toList();
    }

    // Filter by province
    if (province != null && province.isNotEmpty) {
      filtered = filtered.where((d) => d.province == province).toList();
    }

    // Filter by district
    if (district != null && district.isNotEmpty) {
      filtered = filtered.where((d) => d.district == district).toList();
    }

    // Filter by search query (name, district, local level)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        final query = searchQuery.toLowerCase();
        return d.name.toLowerCase().contains(query) ||
            d.district.toLowerCase().contains(query) ||
            d.localLevel.toLowerCase().contains(query) ||
            d.bloodGroup.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }
}

/// Result class for donor search
class DonorSearchResult {
  final bool success;
  final List<Donor> donors;
  final int count;
  final SearchCenter? searchCenter;
  final SearchFilters? filters;
  final String message;

  DonorSearchResult({
    required this.success,
    required this.donors,
    required this.message,
    this.count = 0,
    this.searchCenter,
    this.filters,
  });
}

/// Search center coordinates
class SearchCenter {
  final double latitude;
  final double longitude;
  final double radiusKm;

  SearchCenter({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });
}

/// Applied search filters
class SearchFilters {
  final String bloodGroup;

  SearchFilters({required this.bloodGroup});
}

/// Available filter options
class FilterOption {
  final String value;
  final String label;

  FilterOption({required this.value, required this.label});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value'],
      label: json['label'],
    );
  }
}

class FilterOptions {
  final List<FilterOption> bloodGroups;
  final List<FilterOption> radiusOptions;

  FilterOptions({
    required this.bloodGroups,
    required this.radiusOptions,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      bloodGroups: (json['blood_groups'] as List)
          .map((item) => FilterOption.fromJson(item))
          .toList(),
      radiusOptions: (json['radius_options'] as List)
          .map((item) => FilterOption.fromJson(item))
          .toList(),
    );
  }
}
