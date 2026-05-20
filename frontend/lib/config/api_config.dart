class ApiConfig {
  // ═══════════════════════════════════════════════════════════════════════════════
  // 🚀 EASY PLATFORM SWITCH - CHANGE ONLY THIS LINE!
  // ═══════════════════════════════════════════════════════════════════════════════
  // Options: 'phone', 'emulator', 'desktop', 'ios'
  static const String currentPlatform = 'emulator';  // ← CHANGE THIS!

  // Base URL configuration
  static const String emulatorUrl = 'http://10.0.2.2:8000';      // Android Emulator
  static const String deviceUrl = 'http://192.168.18.87:8000';    // Physical Phone
  static const String localUrl = 'http://localhost:8000';         // Desktop/Web
  static const String iosUrl = 'http://127.0.0.1:8000';          // iOS Simulator

  // Auto-selects URL based on currentPlatform
  static String get baseUrl {
    switch (currentPlatform) {
      case 'emulator':
        return emulatorUrl;
      case 'phone':
        return deviceUrl;
      case 'desktop':
        return localUrl;
      case 'ios':
        return iosUrl;
      default:
        return deviceUrl; // Default to phone
    }
  }

  // UNCOMMENT the line below if testing on physical device:
  // static String get baseUrl => deviceUrl;

  // UNCOMMENT the line below if testing on web:
  // static String get baseUrl => localUrl;

  // API Endpoints
  static String get registerEndpoint => '$baseUrl/api/accounts/register/';
  static String get loginEndpoint => '$baseUrl/api/accounts/login/';
  static String get logoutEndpoint => '$baseUrl/api/accounts/logout/';
  static String get profileEndpoint => '$baseUrl/api/accounts/profile/';
  static String get donorRegisterEndpoint => '$baseUrl/api/accounts/donor/register/';
  static String get forgotPasswordEndpoint => '$baseUrl/api/accounts/forgot-password/';
  static String get resetPasswordEndpoint => '$baseUrl/api/accounts/reset-password/';

  // Blood Request Endpoints
  static String get bloodRequestListEndpoint => '$baseUrl/api/blood-requests/';
  static String get bloodRequestCreateEndpoint => '$baseUrl/api/blood-requests/create/';
  static String get bloodRequestMyRequestsEndpoint => '$baseUrl/api/blood-requests/my-requests/';
  static String bloodRequestDetailEndpoint(int id) => '$baseUrl/api/blood-requests/$id/';

  // Location Data Endpoints
  static String get provincesEndpoint => '$baseUrl/api/blood-requests/provinces/';
  static String get districtsEndpoint => '$baseUrl/api/blood-requests/districts/';
  static String get localLevelsEndpoint => '$baseUrl/api/blood-requests/local-levels/';
  static String get bloodGroupsEndpoint => '$baseUrl/api/blood-requests/blood-groups/';
  static String get gendersEndpoint => '$baseUrl/api/blood-requests/genders/';

  // Timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
