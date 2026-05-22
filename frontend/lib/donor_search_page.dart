import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/donor_model.dart';
import '../services/donor_service.dart';
import '../services/location_service.dart';
import '../widgets/donor_card.dart';
import '../utils/dummy_donors.dart';

class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({super.key});

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage> {
  bool _isLoading = true;
  bool _isGettingLocation = false;
  String? _errorMessage;

  // Location data
  Position? _currentPosition;
  double _selectedRadius = 50;
  String? _selectedBloodGroup;

  // Results
  List<Donor> _donors = [];
  int _donorCount = 0;

  // Filter options
  final List<String> _bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<double> _radiusOptions = [10, 20, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _initializeAndSearch();
  }

  Future<void> _initializeAndSearch() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      await _searchDonors();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
        _errorMessage = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  Future<void> _searchDonors() async {
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = 'Please get your location first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try API first (commented out for testing with dummy data)
      /*
      final result = await DonorService.fetchDonorsNearby(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: _selectedRadius,
        bloodGroup: _selectedBloodGroup == 'All' ? null : _selectedBloodGroup,
      );
      */

      // For testing: Always use dummy donors
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Use dummy donors for testing
          _donors = _filterDummyDonors();
          _donorCount = _donors.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Use dummy donors on error
          _donors = _filterDummyDonors();
          _donorCount = _donors.length;
        });
      }
    }
  }

  List<Donor> _filterDummyDonors() {
    // Get all dummy donors
    List<Donor> donors = DummyDonors.getDonorsNearby(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // Filter by radius
    donors = donors.where((d) {
      if (d.distance != null) {
        return d.distance! <= _selectedRadius;
      }
      return true;
    }).toList();

    // Filter by blood group
    if (_selectedBloodGroup != null && _selectedBloodGroup != 'All') {
      donors = donors.where((d) => d.bloodGroup == _selectedBloodGroup).toList();
    }

    return donors;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Donors',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Blood Group Filter
              const Text(
                'Blood Group',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return FilterChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedBloodGroup = selected ? group : null;
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.red.shade100,
                    checkmarkColor: Colors.red.shade700,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Radius Filter
              const Text(
                'Search Radius',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              // Slider for radius
              Slider(
                value: _selectedRadius,
                min: 10,
                max: 200,
                divisions: 19,
                label: '${_selectedRadius.toInt()} km',
                onChanged: (value) {
                  setModalState(() {
                    _selectedRadius = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('10 km', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(
                      '${_selectedRadius.toInt()} km',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('200 km', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Quick radius options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _radiusOptions.map((radius) {
                  final isSelected = _selectedRadius == radius;
                  return ChoiceChip(
                    label: Text('${radius.toInt()} km'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedRadius = radius;
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.red.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.red.shade700 : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Apply filters and search
                    });
                    Navigator.pop(context);
                    _searchDonors();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: const Text(
          'Find Blood Donors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isGettingLocation) {
      return _buildLoadingState('Getting your location...');
    }

    if (_errorMessage != null && _donors.isEmpty) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingState('Searching for donors...');
    }

    if (_donors.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDonorsList();
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeAndSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Donors Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No donors found within $_selectedRadius km${_selectedBloodGroup != null && _selectedBloodGroup != "All" ? " with blood group $_selectedBloodGroup" : ""}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.filter_list),
              label: const Text('Change Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorsList() {
    return RefreshIndicator(
      onRefresh: _searchDonors,
      color: Colors.red.shade700,
      child: Column(
        children: [
          // Results header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_donorCount Donor${_donorCount != 1 ? "s" : ""} Found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Within $_selectedRadius km of your location${_selectedBloodGroup != null && _selectedBloodGroup != "All" ? " • Blood group: $_selectedBloodGroup" : ""}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Donors list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _donors.length,
              itemBuilder: (context, index) {
                final donor = _donors[index];
                return DonorCard(donor: donor);
              },
            ),
          ),
        ],
      ),
    );
  }
}
