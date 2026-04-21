import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'models/donor_model.dart';
import 'services/location_service.dart';
import 'services/donor_service.dart';
import 'widgets/donor_card.dart';

class MapDonorPage extends StatefulWidget {
  final String? selectedBloodGroup;

  const MapDonorPage({
    super.key,
    this.selectedBloodGroup,
  });

  @override
  State<MapDonorPage> createState() => _MapDonorPageState();
}

class _MapDonorPageState extends State<MapDonorPage> {
  // Map controller
  GoogleMapController? _mapController;

  // Location
  Position? _currentPosition;
  LatLng? _currentLatLng;

  // Donors
  List<Donor> _nearbyDonors = [];
  Set<Marker> _markers = {};

  // State
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      await _getCurrentLocation();

      // Load nearby donors
      await _loadNearbyDonors();

      // Create markers
      _createMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLatLng!,
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Could not get your location: $e";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadNearbyDonors() async {
    List<Donor> allDonors = await DonorService.fetchDonors();

    // Filter by blood group if selected
    List<Donor> filteredDonors = widget.selectedBloodGroup != null
        ? DonorService.filterDonors(
            allDonors,
            bloodGroup: widget.selectedBloodGroup,
          )
        : allDonors;

    // Calculate distances from current location
    List<Donor> donorsWithDistance = [];
    for (var donor in filteredDonors) {
      double distance = LocationService.calculateDistance(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
        donor.latitude,
        donor.longitude,
      );

      // Create new donor with calculated distance
      donorsWithDistance.add(Donor(
        id: donor.id,
        name: donor.name,
        bloodGroup: donor.bloodGroup,
        province: donor.province,
        district: donor.district,
        localLevel: donor.localLevel,
        phone: donor.phone,
        email: donor.email,
        lastDonationDate: donor.lastDonationDate,
        totalDonations: donor.totalDonations,
        isAvailable: donor.isAvailable,
        gender: donor.gender,
        distance: distance,
        latitude: donor.latitude,
        longitude: donor.longitude,
      ));
    }

    // Sort by distance and show nearby donors (within 50km)
    setState(() {
      _nearbyDonors = donorsWithDistance
          .where((d) => d.distance! < 50) // Within 50km
          .toList()
        ..sort((a, b) => a.distance!.compareTo(b.distance!));
    });
  }

  void _createMarkers() {
    Set<Marker> markers = {};

    // Add current location marker
    if (_currentLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }

    // Add donor markers
    for (var donor in _nearbyDonors) {
      final markerId = MarkerId(donor.id);
      final markerIcon = donor.isAvailable
          ? BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            )
          : BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            );

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(donor.latitude, donor.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: donor.name,
            snippet: '${donor.bloodGroup} • ${donor.distance!.toStringAsFixed(1)} km away',
          ),
          onTap: () {
            _showDonorDetails(donor);
          },
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showDonorDetails(Donor donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDonorBottomSheet(donor),
    );
  }

  Widget _buildDonorBottomSheet(Donor donor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Donor details
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DonorCard(donor: donor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: Text(
          widget.selectedBloodGroup != null
              ? 'Nearby ${widget.selectedBloodGroup} Donors'
              : 'Nearby Donors',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // List view button
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              // Navigate to list view
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Map
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLatLng ?? const LatLng(27.7172, 85.3240),
                        zoom: 12,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                    ),

                    // Blood group filter bar (if selected)
                    if (widget.selectedBloodGroup != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: _buildBloodGroupFilter(isDark),
                      ),

                    // Donors list toggle button
                    if (_nearbyDonors.isNotEmpty)
                      Positioned(
                        right: 10,
                        bottom: 100,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            // Show donors list in bottom sheet
                            _showDonorsList();
                          },
                          child: const Icon(Icons.list, color: Color(0xFFB71C1C)),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildBloodGroupFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFB71C1C),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.bloodtype, color: Color(0xFFB71C1C), size: 20),
          const SizedBox(width: 8),
          Text(
            'Blood Group: ${widget.selectedBloodGroup}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            'Found ${_nearbyDonors.length} donors',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDonorsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Color(0xFFB71C1C)),
                      const SizedBox(width: 8),
                      Text(
                        'Nearby Donors (${_nearbyDonors.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Donors list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _nearbyDonors.length,
                    itemBuilder: (context, index) {
                      final donor = _nearbyDonors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getBloodGroupColor(donor.bloodGroup),
                            child: Text(
                              donor.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(donor.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${donor.distance!.toStringAsFixed(1)} km away'),
                              Text(donor.localLevel),
                            ],
                          ),
                          trailing: Icon(
                            donor.isAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: donor.isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showDonorDetails(donor);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Unable to load map',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please enable location services'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeMap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'A+':
      case 'A-':
        return Colors.blue;
      case 'B+':
      case 'B-':
        return Colors.green;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      case 'O+':
      case 'O-':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
