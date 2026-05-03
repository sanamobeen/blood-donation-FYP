import 'package:flutter/material.dart';
import 'widgets/sos/sos_button.dart';
import 'package:geolocator/geolocator.dart';
import 'emergency_contacts_page.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool _isSOSActive = false;
  final EmergencyContactsService _contactsService = EmergencyContactsService();
  final LocationService _locationService = LocationService();
  final SOSNotificationService _notificationService = SOSNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _contactsService.loadContacts();
    await _notificationService.initialize();
    await _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final currentPosition = await _locationService.getCurrentLocation();
      if (currentPosition == null && mounted) {
        // Check if location is permanently denied
        final isPermanentlyDenied = await _locationService.isLocationPermanentlyDenied();
        final isServiceDisabled = await _locationService.isLocationServiceDisabled();

        if (!mounted) return;

        if (isPermanentlyDenied) {
          _showLocationSettingsDialog();
        } else if (isServiceDisabled) {
          _showEnableLocationDialog();
        } else {
          setState(() {}); // Trigger rebuild
        }
      } else if (mounted) {
        setState(() {}); // Location obtained, trigger rebuild
      }
    } catch (e) {
      if (mounted) {
        _showLocationErrorDialog(e.toString());
      }
    }
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Location Permission Required'),
          ],
        ),
        content: const Text(
          'Location permission was permanently denied. Please enable it in your device settings to use the SOS feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showEnableLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Enable Location Services'),
          ],
        ),
        content: const Text(
          'Please enable location services on your device to use the SOS feature. Location is required to send your emergency contacts your exact position.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Location Error'),
          ],
        ),
        content: Text('Failed to get location: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: const Text('Emergency SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "EMERGENCY SOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Long press the button below for 3 seconds to send emergency alerts",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // SOS Button Section
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SOSButton(
                    onLocationObtained: (Position position) {
                      // Location callback - can be used to show map or perform other actions
                    },
                    testMode: false,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            const Text(
                              "How it works",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "• Long press the SOS button for 3 seconds\n"
                          "• Confirm the emergency alert\n"
                          "• Your GPS location will be detected\n"
                          "• SMS app opens with your location\n"
                          "• Send the message to your emergency contacts",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contacts Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyContactsPage()),
                      );
                    },
                    icon: const Icon(Icons.contact_phone),
                    label: const Text(
                      "Manage Emergency Contacts",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

