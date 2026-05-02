import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isTracking => _isTracking;

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<bool> isLocationPermanentlyDenied() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  Future<bool> isLocationServiceDisabled() async {
    return !await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    if (!await _checkPermission()) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      await _getAddressFromCoordinates(position);
      return position;
    } catch (e) {
      // Error getting location: $e
      return null;
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      // Error getting address: $e
      _currentAddress = 'Unknown location';
    }
  }

  String getLocationURL() {
    if (_currentPosition == null) return '';
    return 'https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
  }

  String getLocationMessage() {
    if (_currentPosition == null) return 'Location not available';

    return '''
Latitude: ${_currentPosition!.latitude}
Longitude: ${_currentPosition!.longitude}
Address: $_currentAddress
Map: ${getLocationURL()}
''';
  }

  double distanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return double.infinity;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  bool isInSafeZone(List<LatLng> safeZones) {
    if (_currentPosition == null) return false;

    return safeZones.any((zone) =>
      distanceTo(zone.latitude, zone.longitude) < 100 // 100m radius
    );
  }

  Future<void> startLocationTracking() async {
    _isTracking = true;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _getAddressFromCoordinates(position);
    });
  }

  Future<void> stopLocationTracking() async {
    _isTracking = false;
  }
}