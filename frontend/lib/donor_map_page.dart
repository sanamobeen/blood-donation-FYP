import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'models/donor_model.dart';
import 'utils/mock_data.dart';
import 'widgets/donor_card.dart';

class DonorMapPage extends StatefulWidget {
  final String? bloodGroupFilter;
  final String? searchQuery;

  const DonorMapPage({
    super.key,
    this.bloodGroupFilter,
    this.searchQuery,
  });

  @override
  State<DonorMapPage> createState() => _DonorMapPageState();
}

class _DonorMapPageState extends State<DonorMapPage> {
  MapController? _mapController;
  List<Marker> _markers = [];
  List<Donor> _donors = [];
  bool _isLoading = true;
  Position? _currentPosition;

  // Initial camera position (Islamabad, Pakistan)
  static final LatLng _initialPosition = LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      _currentPosition = await _getCurrentLocation();

      // Load donors
      List<Donor> allDonors = MockDonorData.getMockDonors();

      // Filter donors if filters are provided
      if (widget.bloodGroupFilter != null || widget.searchQuery != null) {
        _donors = _filterDonors(allDonors);
      } else {
        _donors = allDonors;
      }

      // Create markers
      _createMarkers();

      // Move camera to show all markers or current location
      _moveCameraToShowDonors();
    } catch (e) {
      // Silently handle error - will show empty state
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Donor> _filterDonors(List<Donor> donors) {
    List<Donor> filtered = List.from(donors);

    // Filter by blood group
    if (widget.bloodGroupFilter != null && widget.bloodGroupFilter!.isNotEmpty) {
      filtered = filtered.where((d) => d.bloodGroup == widget.bloodGroupFilter).toList();
    }

    // Filter by search query
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      filtered = filtered.where((d) {
        final query = widget.searchQuery!.toLowerCase();
        return d.name.toLowerCase().contains(query) ||
            d.district.toLowerCase().contains(query) ||
            d.localLevel.toLowerCase().contains(query) ||
            d.bloodGroup.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _createMarkers() {
    List<Marker> markers = [];

    for (Donor donor in _donors) {
      // Create different marker colors based on availability
      final markerColor = donor.isAvailable ? Colors.green : Colors.red;

      final marker = Marker(
        width: 40,
        height: 40,
        point: LatLng(donor.latitude, donor.longitude),
        child: GestureDetector(
          onTap: () {
            _showDonorBottomSheet(donor);
          },
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    donor.bloodGroup,
                    style: TextStyle(
                      color: markerColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      markers.add(marker);
    }

    // Add current location marker if available
    if (_currentPosition != null) {
      final currentLocationMarker = Marker(
        width: 40,
        height: 40,
        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
      markers.add(currentLocationMarker);
    }

    setState(() {
      _markers = markers;
    });
  }

  void _moveCameraToShowDonors() {
    if (_donors.isEmpty) return;

    if (_currentPosition != null && _donors.isNotEmpty) {
      // Center between current location and nearest donor
      _mapController?.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        12.0,
      );
    } else if (_donors.isNotEmpty) {
      // Show first donor location
      _mapController?.move(
        LatLng(_donors[0].latitude, _donors[0].longitude),
        10.0,
      );
    }
  }

  void _showDonorBottomSheet(Donor donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DonorCard(
                  donor: donor,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController?.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14.0,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location not available'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
          'Donor Locations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _centerOnCurrentLocation,
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 10.0,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  mapController: _mapController,
                  children: [
                    // OpenStreetMap tile layer
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.blood_bank',
                      maxZoom: 19,
                    ),
                    // Marker layer
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),
                if (_donors.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black87 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.red.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_donors.length} donor${_donors.length > 1 ? 's' : ''} found',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (widget.bloodGroupFilter != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.bloodGroupFilter!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_donors.isEmpty && !_isLoading)
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No donors found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Blood Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((group) {
              return ListTile(
                title: Text(group),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonorMapPage(
                        bloodGroupFilter: group,
                        searchQuery: widget.searchQuery,
                      ),
                    ),
                  );
                },
              );
            }),
            ListTile(
              title: const Text('Clear Filter'),
              leading: const Icon(Icons.clear),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonorMapPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}