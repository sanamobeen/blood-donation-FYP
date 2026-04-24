import 'package:flutter/material.dart';
import 'donor_map_page.dart';
import 'utils/mock_data.dart';
import 'widgets/donor_card.dart';
import 'models/donor_model.dart';
import 'services/donor_service.dart';

class FindDonorsPage extends StatefulWidget {
  const FindDonorsPage({super.key});

  @override
  State<FindDonorsPage> createState() => _FindDonorsPageState();
}

class _FindDonorsPageState extends State<FindDonorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedProvince;
  String? _selectedDistrict;
  List<Donor> _filteredDonors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Donor> donors = await DonorService.fetchDonors();
      _filteredDonors = _applyFilters(donors);
    } catch (e) {
      // Silently handle error - show empty list
      _filteredDonors = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Donor> _applyFilters(List<Donor> donors) {
    return DonorService.filterDonors(
      donors,
      bloodGroup: _selectedBloodGroup,
      province: _selectedProvince,
      district: _selectedDistrict,
      searchQuery: _searchQuery,
    );
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonorMapPage(
          bloodGroupFilter: _selectedBloodGroup,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Donors'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blood Group',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockDonorData.getBloodGroups().map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return FilterChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBloodGroup = selected ? group : null;
                      });
                      Navigator.pop(context);
                      _showFilterDialog();
                    },
                    selectedColor: Colors.red.shade100,
                    checkmarkColor: Colors.red.shade900,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Province',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...MockDonorData.getProvinces().map((province) {
                return CheckboxListTile(
                  title: Text(province),
                  value: _selectedProvince == province,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedProvince = value! ? province : null;
                      _selectedDistrict = null; // Reset district when province changes
                    });
                    Navigator.pop(context);
                    _showFilterDialog();
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 16),
              if (_selectedProvince != null) ...[
                const Text(
                  'District',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...MockDonorData.getDistricts(_selectedProvince!).map((district) {
                  return CheckboxListTile(
                    title: Text(district),
                    value: _selectedDistrict == district,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedDistrict = value! ? district : null;
                      });
                      Navigator.pop(context);
                      _showFilterDialog();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedBloodGroup = null;
                        _selectedProvince = null;
                        _selectedDistrict = null;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      Navigator.pop(context);
                      _loadDonors();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _loadDonors();
    });
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
          'Find Donors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: _navigateToMap,
            tooltip: 'View on Map',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar with map navigation
                GestureDetector(
                  onTap: _navigateToMap,
                  child: AbsorbPointer(
                    absorbing: false,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by location or name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: _navigateToMap,
                              tooltip: 'View on Map',
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                  _loadDonors();
                                },
                              ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        // Debounce search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchQuery == value) {
                            _loadDonors();
                          }
                        });
                      },
                      onSubmitted: (value) {
                        _loadDonors();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Active filters display
                if (_selectedBloodGroup != null ||
                    _selectedProvince != null ||
                    _selectedDistrict != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedBloodGroup != null)
                        Chip(
                          label: Text(_selectedBloodGroup!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedBloodGroup = null;
                            });
                            _loadDonors();
                          },
                          backgroundColor: Colors.red.shade100,
                          labelStyle: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_selectedProvince != null)
                        Chip(
                          label: Text(_selectedProvince!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedProvince = null;
                              _selectedDistrict = null;
                            });
                            _loadDonors();
                          },
                          backgroundColor: Colors.blue.shade100,
                        ),
                      if (_selectedDistrict != null)
                        Chip(
                          label: Text(_selectedDistrict!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedDistrict = null;
                            });
                            _loadDonors();
                          },
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),

                // Results count
                if (!_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Text(
                          '${_filteredDonors.length} donor${_filteredDonors.length > 1 ? 's' : ''} found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _navigateToMap,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('View on Map'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Donors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDonors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
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
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedBloodGroup = null;
                                  _selectedProvince = null;
                                  _selectedDistrict = null;
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                                _loadDonors();
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade900,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDonors,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = _filteredDonors[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  // Show donor details or navigate to detail page
                                  _showDonorDetails(donor);
                                },
                                child: DonorCard(
                                  donor: donor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToMap,
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.map),
        label: const Text('View on Map'),
      ),
    );
  }

  void _showDonorDetails(Donor donor) {
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Make phone call
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonorMapPage(
                                searchQuery: donor.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
