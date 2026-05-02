import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/sos/sos_button.dart';
import 'services/emergency_contacts_service.dart';
import 'services/location_service.dart';
import 'services/sos_notification_service.dart';

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
        title: const Text(
          'Emergency SOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isSOSActive) _buildActiveAlertBanner(),
              const SizedBox(height: 20),

              _buildInfoCard(
                icon: Icons.info_outline,
                title: 'How SOS Works',
                description: 'Hold the SOS button for 3 seconds to send emergency alerts to your contacts with your location.',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.security,
                title: 'Privacy Protected',
                description: 'Your location is only shared during emergencies. All data is encrypted and stored locally.',
                color: Colors.green,
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SOSButton(
                      showLabels: true,
                      testMode: true, // Enable test mode for easier testing
                      onSOSStateChanged: (isActive) {
                        setState(() {
                          _isSOSActive = isActive;
                        });
                      },
                      onSOSActivatedWithLocation: (isActive, location) {
                        if (isActive && location != null) {
                          // Automatically show map when SOS is activated
                          _showSOSLocationMap(location);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Location tracking indicator
                    _buildLocationIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Quick test button for easier testing
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate SOS activation for testing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🚨 Quick Test: SOS activated! (Long-press the red button for full experience)'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                icon: const Icon(Icons.bolt),
                label: const Text('Quick Test SOS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS IS ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Emergency alerts have been sent to your contacts',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.contact_phone,
                label: 'Emergency Contacts',
                color: Colors.blue,
                onTap: () => _showContactsDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.location_on,
                label: 'Test Location',
                color: Colors.green,
                onTap: () => _testLocation(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.2), // Visual feedback when tapped
        child: Container(
          padding: const EdgeInsets.all(20), // Increased padding for larger touch area
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32), // Larger icon
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13, // Slightly larger text
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPosition = _locationService.currentPosition;
    final currentAddress = _locationService.currentAddress;

    return InkWell(
      onTap: currentPosition != null ? () => _showLocationMap() : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: currentPosition != null ? Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 2,
          ) : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentPosition != null ? Icons.location_on : Icons.location_off,
                  color: currentPosition != null ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  currentPosition != null ? 'Tap to see map' : 'Location Not Available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            if (currentPosition != null) ...[
              const SizedBox(height: 8),
              Text(
                '📍 ${currentAddress ?? "Getting address..."}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${currentPosition.latitude.toStringAsFixed(4)}, ${currentPosition.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 12, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view on map',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _requestLocationPermission(),
                icon: const Icon(Icons.location_searching, size: 16),
                label: const Text('Enable Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(0, 32),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text('Manage Emergency Contacts'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showContactsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showLocationSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Usage History'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showUsageHistory();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactsDialog() {
    final contacts = _contactsService.contacts;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.contacts),
            const SizedBox(width: 8),
            const Text('Emergency Contacts'),
          ],
        ),
        content: contacts.isEmpty
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_phone, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No emergency contacts configured'),
                  SizedBox(height: 8),
                  Text(
                    'Add at least one contact to use SOS',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: contacts.map((contact) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(contact.name),
                    subtitle: Text(contact.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final navigatorContext = context;
                        await _contactsService.removeContact(contact.id);
                        if (!mounted) return;
                        setState(() {});
                        if (!navigatorContext.mounted) return;
                        Navigator.pop(navigatorContext);
                        if (!mounted) return;
                        _showContactsDialog();
                      },
                    ),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (contacts.isEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addContactDialog();
              },
              child: const Text('Add Contact'),
            ),
        ],
      ),
    );
  }

  void _addContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigatorContext = context;
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                final contact = EmergencyContact(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phone: phoneController.text,
                );
                await _contactsService.addContact(contact);
                if (!mounted) return;
                setState(() {});
                if (!navigatorContext.mounted) return;
                Navigator.pop(navigatorContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _testLocation() async {
    final location = await _locationService.getCurrentLocation();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_on),
            const SizedBox(width: 8),
            const Text('Current Location'),
          ],
        ),
        content: location == null
            ? const Text('Unable to get location. Please check your permissions.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: ${location.latitude}'),
                  Text('Longitude: ${location.longitude}'),
                  const SizedBox(height: 8),
                  Text('Address: ${_locationService.currentAddress ?? "Unknown"}'),
                  const SizedBox(height: 8),
                  Text(
                    'Map URL: ${_locationService.getLocationURL()}',
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.high_quality),
              title: Text('High Accuracy Mode'),
              subtitle: Text('Uses GPS for precise location'),
            ),
            ListTile(
              leading: Icon(Icons.battery_alert),
              title: Text('Battery Saving'),
              subtitle: Text('Uses WiFi & mobile networks'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUsageHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usage History'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('No recent activations'),
              subtitle: Text('Your SOS usage history will appear here'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLocationMap() {
    final currentPosition = _locationService.currentPosition;
    if (currentPosition == null) return;

    final userLocation = LatLng(currentPosition.latitude, currentPosition.longitude);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red.shade900,
            title: const Text('Your Location', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: FlutterMap(
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.blood_bank',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: userLocation,
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSOSLocationMap(dynamic position) {
    if (position == null) return;

    final userLocation = LatLng(position.latitude, position.longitude);
    final currentAddress = _locationService.currentAddress ?? "Getting address...";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red.shade900,
              title: const Text('🚨 SOS Location', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'SOS ACTIVE',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: userLocation,
                    initialZoom: 16.0,
                    minZoom: 12.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.blood_bank',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 100.0,
                          height: 100.0,
                          point: userLocation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.sos,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Location info overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your Emergency Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Emergency alerts have been sent to your contacts with this location.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}