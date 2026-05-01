class ApiConfig {
  // Base URL configuration - automatically detects the best URL to use

  // For Android emulator trying to connect to host machine
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  // For physical device on the same network (replace with your computer's IP)
  static const String deviceUrl = 'http://192.168.56.1:8000';  // Your PC's current IP

  // For testing on same machine (web debug)
  static const String localUrl = 'http://localhost:8000';

  // For iOS simulator
  static const String iosUrl = 'http://127.0.0.1:8000';

  // Try multiple URLs in order
  static String get baseUrl {
    // Try emulator first, then device URL if emulator fails
    return deviceUrl;  // Changed to device URL for more reliable connection
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
  static String get provincesEndpoint => '$baseUrl/api/accounts/locations/provinces/';
  static String get districtsEndpoint => '$baseUrl/api/accounts/locations/districts/';
  static String get localLevelsEndpoint => '$baseUrl/api/accounts/locations/local-levels/';
  static String get bloodGroupsEndpoint => '$baseUrl/api/accounts/locations/blood-groups/';
  static String get gendersEndpoint => '$baseUrl/api/accounts/locations/genders/';

  // Timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
