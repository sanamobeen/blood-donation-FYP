import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Authentication service for handling user registration, login, and token management
/// Separates authentication logic from UI components for better code organization
class AuthService {
  /// Register a new user with the given data
  ///
  /// Returns [AuthResult] with success status and user data/tokens if successful
  /// Returns error message if registration fails
  static Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String province,
    required String district,
    required String localLevel,
    required String dateOfBirth,
    required String bloodGroup,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validate input
      if (password != confirmPassword) {
        return AuthResult.failure('Passwords do not match');
      }

      // Prepare registration data
      final registrationData = {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'gender': gender,
        'province': province,
        'district': district,
        'local_level': localLevel.trim(),
        'date_of_birth': dateOfBirth,
        'blood_group': bloodGroup,
        'password': password,
        'confirm_password': confirmPassword,
      };

      // Registration data logging for development
      if (kDebugMode) {
        print('Registration data: $registrationData');
      }

      // Make API call to backend
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
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

      // Handle successful registration
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Store JWT tokens and user data
          await _storeAuthData(responseData['data']);

          return AuthResult.success(
            userData: responseData['data']['user'],
            message: responseData['message'] ?? 'Registration successful',
          );
        } else {
          return AuthResult.failure(responseData['message'] ?? 'Registration failed');
        }
      }

      // Handle error response
      final errorData = jsonDecode(response.body);
      String errorMessage = 'Registration failed';

      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final errorList = errors[firstErrorKey];
          if (errorList is List && errorList.isNotEmpty) {
            errorMessage = errorList[0].toString();
          }
        }
      } else if (errorData.containsKey('message')) {
        errorMessage = errorData['message'];
      }

      return AuthResult.failure(errorMessage);

    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }

      // Determine specific error message
      String errorMessage = 'Registration failed';
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Connection') || e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Please check if backend is running.';
      }

      return AuthResult.failure(errorMessage);
    }
  }

  /// Login user with email and password
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = {
        'email': email.trim().toLowerCase(),
        'password': password,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      ).timeout(
        ApiConfig.connectTimeout,
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          await _storeAuthData(responseData['data']);

          return AuthResult.success(
            userData: responseData['data']['user'],
            message: responseData['message'] ?? 'Login successful',
          );
        }
      }

      // Handle error
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'Login failed';
      return AuthResult.failure(errorMessage);

    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return AuthResult.failure('Connection error. Please try again.');
    }
  }

  /// Logout user and clear stored data
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      // Call backend logout endpoint if we have a refresh token
      if (refreshToken != null) {
        await http.post(
          Uri.parse(ApiConfig.logoutEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refreshToken}),
        ).timeout(ApiConfig.connectTimeout);
      }

      // Clear local storage
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.setBool('is_logged_in', false);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      // Even if backend call fails, clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return false;
    }
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Get current logged in user data
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
    };
  }

  /// Get stored access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Store authentication data from successful login/registration
  static Future<void> _storeAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final tokens = data['tokens'];
    final user = data['user'];

    await prefs.setString('access_token', tokens['access']);
    await prefs.setString('refresh_token', tokens['refresh']);
    await prefs.setString('user_email', user['email']);
    await prefs.setString('user_name', user['full_name'] ?? 'User');
    await prefs.setBool('is_logged_in', true);
  }
}

/// Result class for authentication operations
/// Provides a clean way to handle success/failure states
class AuthResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String? message;

  AuthResult._({
    required this.success,
    this.userData,
    this.message,
  });

  /// Create successful result
  factory AuthResult.success({
    required Map<String, dynamic> userData,
    String? message,
  }) {
    return AuthResult._(
      success: true,
      userData: userData,
      message: message,
    );
  }

  /// Create failure result
  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      success: false,
      message: errorMessage,
    );
  }

  /// Get error message for failed operations
  String get errorMessage => message ?? 'Unknown error occurred';

  /// Get user-friendly message for display
  String get displayMessage => message ?? (success ? 'Operation successful' : 'Operation failed');
}

