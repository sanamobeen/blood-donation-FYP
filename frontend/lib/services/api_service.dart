import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for making authenticated API requests with JWT tokens
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8001/api';

  /// Get stored JWT access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Get stored JWT refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// Refresh access token using refresh token
  static Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseData['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Make authenticated GET request
  static Future<http.Response> get(String endpoint) async {
    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        return await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
      }
    }

    return response;
  }

  /// Make authenticated POST request
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      String? accessToken = await getAccessToken();
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    // If unauthorized, try to refresh token and retry
    if (requireAuth && response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        String? accessToken = await getAccessToken();
        headers['Authorization'] = 'Bearer $accessToken';
        return await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }

  /// Make authenticated PUT request
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    String? accessToken = await getAccessToken();

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        return await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return response;
  }

  /// Make authenticated DELETE request
  static Future<http.Response> delete(String endpoint) async {
    String? accessToken = await getAccessToken();

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        return await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
      }
    }

    return response;
  }

  /// Logout user and clear tokens
  static Future<bool> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      // Call backend logout endpoint to blacklist token
      await http.post(
        Uri.parse('$baseUrl/accounts/logout/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      // Clear local tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.setBool('is_logged_in', false);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Get current user data
  static Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
    };
  }
}