import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing_page.dart';
import 'models/blood_request_model.dart';
import 'services/blood_request_service.dart';

class BloodDonationFormPage extends StatefulWidget {
  const BloodDonationFormPage({super.key});

  @override
  State<BloodDonationFormPage> createState() => _BloodDonationFormPageState();
}

class _BloodDonationFormPageState extends State<BloodDonationFormPage> {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _caseController = TextEditingController();
  final _localLevelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Selection State Variables (String IDs for API)
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  TimeOfDay? _selectedTime;
  String? _selectedProvince;
  String? _selectedDistrict;

  // API Data Lists
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<BloodGroup> _bloodGroups = [];
  List<Gender> _genders = [];

  // Loading State
  // ignore: prefer_final_fields
  bool _isLoading = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      // Load provinces
      final provincesResult = await BloodRequestService.getProvinces();
      debugPrint('Provinces result: ${provincesResult.success}, count: ${provincesResult.provinces?.length}');
      if (provincesResult.success && provincesResult.provinces != null) {
        // Sort provinces in the desired order: Punjab, Sindh, KPK, Balochistan
        final provinceOrder = ['Punjab', 'Sindh', 'Khyber Pakhtunkhwa', 'Balochistan'];
        final sortedProvinces = List<Province>.from(provincesResult.provinces!);
        sortedProvinces.sort((a, b) {
          int indexA = provinceOrder.indexOf(a.name);
          int indexB = provinceOrder.indexOf(b.name);
          if (indexA == -1) indexA = 999;
          if (indexB == -1) indexB = 999;
          return indexA.compareTo(indexB);
        });

        setState(() {
          _provinces = sortedProvinces;
        });
      } else {
        debugPrint('Failed to load provinces: ${provincesResult.errorMessage}');
      }

      // Load blood groups
      final bloodGroupsResult = await BloodRequestService.getBloodGroups();
      debugPrint('Blood groups result: ${bloodGroupsResult.success}, count: ${bloodGroupsResult.bloodGroups?.length}');
      if (bloodGroupsResult.success && bloodGroupsResult.bloodGroups != null) {
        setState(() {
          _bloodGroups = bloodGroupsResult.bloodGroups!;
        });
      } else {
        debugPrint('Failed to load blood groups: ${bloodGroupsResult.errorMessage}');
      }

      // Load genders
      final gendersResult = await BloodRequestService.getGenders();
      debugPrint('Genders result: ${gendersResult.success}, count: ${gendersResult.genders?.length}');
      if (gendersResult.success && gendersResult.genders != null) {
        setState(() {
          _genders = gendersResult.genders!;
        });
      } else {
        debugPrint('Failed to load genders: ${gendersResult.errorMessage}');
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadDistricts([String? provinceName]) async {
    debugPrint('Loading districts for province: $provinceName');
    final result = await BloodRequestService.getDistricts(provinceName);
    debugPrint('Districts result: ${result.success}, count: ${result.districts?.length}');
    if (result.success && result.districts != null) {
      setState(() {
        _districts = result.districts!;
      });
      debugPrint('Loaded ${_districts.length} districts');
    } else {
      debugPrint('Failed to load districts: ${result.errorMessage}');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load districts: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _caseController.dispose();
    _localLevelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Blood Request",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          _isInitialLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionHeader(isDark, "Personal Information", Icons.person),
              const SizedBox(height: 16),
              _buildTextField(
                isDark,
                "Patient Name",
                Icons.person,
                _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter patient name";
                  }
                  if (value.length < 3) {
                    return "Name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                isDark,
                "Emergency Contact",
                Icons.contact_phone,
                _contactPersonController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter emergency contact";
                  }
                  // Remove all non-digit characters for validation
                  final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

                  // Check if it's a valid Pakistan phone number
                  // Format: +92-3XX-XXXXXXX or 03XX-XXXXXXX
                  if (digitsOnly.length < 10 || digitsOnly.length > 13) {
                    return "Please enter a valid Pakistan phone number";
                  }

                  // Check if it starts with correct prefix
                  if (!digitsOnly.startsWith('92') && !digitsOnly.startsWith('03') && !digitsOnly.startsWith('3')) {
                    return "Phone number must start with +92, 03, or 3";
                  }

                  // Check minimum length for each format
                  if (digitsOnly.startsWith('92') && digitsOnly.length < 12) {
                    return "Invalid phone number format. Use: +92-3XX-XXXXXXX";
                  }
                  if ((digitsOnly.startsWith('03') || digitsOnly.startsWith('3')) && digitsOnly.length < 10) {
                    return "Invalid phone number format. Use: 03XX-XXXXXXX";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildBloodGroupDropdown(isDark),
              const SizedBox(height: 12),
              _buildGenderDropdown(isDark),
              const SizedBox(height: 24),

              // Location Details Section
              _buildSectionHeader(isDark, "Location Details", Icons.location_on),
              const SizedBox(height: 16),
              _buildProvinceDropdown(isDark),
              const SizedBox(height: 12),
              _buildDistrictDropdown(isDark),
              const SizedBox(height: 12),
              _buildTextField(
                isDark,
                "Local Level (Optional)",
                Icons.apartment,
                _localLevelController,
              ),
              const SizedBox(height: 24),

              // Blood Requirement Section
              _buildSectionHeader(isDark, "Blood Requirement", Icons.bloodtype),
              const SizedBox(height: 16),
              _buildTextField(
                isDark,
                "Required pint",
                Icons.bloodtype,
                _weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter required pint";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildDatePicker(
                isDark,
                "Required Date",
                Icons.calendar_today,
                _lastDonationDate,
                (date) => setState(() => _lastDonationDate = date),
              ),
              const SizedBox(height: 12),
              _buildTimePicker(
                isDark,
                "Required time",
                Icons.access_time,
                _selectedTime,
                (time) => setState(() => _selectedTime = time),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: Colors.red.shade900, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Case",
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _caseController,
                      maxLines: 5,
                      minLines: 4,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter case details...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Proceed",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Submitting blood request...",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "Only valid and authentic information must be entered. The submission of non-authentic details will lead to the automatic removal of the application",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 4,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.red.shade900.withValues(alpha: 0.1)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    bool isDark,
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(icon, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    bool isDark,
    String label,
    IconData icon,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        title: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: selectedDate != null ? 16 : 14,
            fontWeight: selectedDate != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          icon,
          color: Colors.red.shade900,
          size: 24,
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(), // Today onwards only
            lastDate: DateTime(2100), // Up to year 2100
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
      ),
    );
  }

  Widget _buildTimePicker(
    bool isDark,
    String label,
    IconData icon,
    TimeOfDay? selectedTime,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        title: Text(
          selectedTime != null
              ? '${(selectedTime.hour == 0 ? 12 : (selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour)).toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}'
              : label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: selectedTime != null ? 16 : 14,
            fontWeight: selectedTime != null ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          icon,
          color: Colors.red.shade900,
          size: 24,
        ),
        onTap: () async {
          // Check if selected date is today, future, or past
          final now = DateTime.now();
          final selectedDate = _lastDonationDate;

          if (selectedDate == null) {
            // Show error - date must be selected first
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select required date first'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          final isToday = selectedDate.year == now.year &&
              selectedDate.month == now.month &&
              selectedDate.day == now.day;

          final isFutureDate = selectedDate.isAfter(DateTime(now.year, now.month, now.day));

          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                child: child!,
              );
            },
          );

          if (picked != null) {
            // Validate time based on selected date
            if (isToday) {
              // For today: time must be current or future (not past)
              final nowDateTime = DateTime.now();

              // Create DateTime object for selected time
              final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

              // Calculate difference in seconds for more accurate comparison
              final difference = selectedDateTime.difference(nowDateTime).inSeconds;

              // Allow only current time and future times (no past times, even 1 minute ago)
              // Use -60 seconds buffer to account for time it takes to select
              if (difference < -60) {
                // Show error - past time not allowed for today
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot select past time. Please choose current or future time.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Current time or near-future time is acceptable
              onTimeSelected(picked);
            } else if (isFutureDate) {
              // For future dates: any time is acceptable
              onTimeSelected(picked);
            } else {
              // Past date (shouldn't happen due to date validation, but handle it)
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot select time for past dates'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          }
        },
      ),
    );
  }

  void _submitForm() async {
    // Step 1: Comprehensive Form Validation
    List<String> errors = [];

    // Validate text fields using form key
    if (!_formKey.currentState!.validate()) {
      // Form validation failed - text fields have errors
      return;
    }

    // Validate dropdowns
    if (_selectedBloodGroup == null) {
      errors.add("• Please select your blood group");
    }
    if (_selectedGender == null) {
      errors.add("• Please select your gender");
    }
    if (_selectedProvince == null) {
      errors.add("• Please select your province");
    }
    if (_selectedDistrict == null) {
      errors.add("• Please select your district");
    }

    // Validate date and time
    if (_lastDonationDate == null) {
      errors.add("• Please select required date");
    }
    if (_selectedTime == null) {
      errors.add("• Please select required time");
    }

    // If there are any validation errors, show them all at once
    if (errors.isNotEmpty) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please complete the following required fields:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 8),
              ...errors.map((error) => Text(
                error,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              )),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Step 2: Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Format date and time
      final formattedDate = '${_lastDonationDate!.year}-${_lastDonationDate!.month.toString().padLeft(2, '0')}-${_lastDonationDate!.day.toString().padLeft(2, '0')}';
      final formattedTime = '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Submit to Backend
      final result = await BloodRequestService.createBloodRequest(
        patientName: _nameController.text.trim(),
        emergencyContact: _contactPersonController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        gender: _selectedGender!,
        province: _selectedProvince!,
        district: _selectedDistrict!,
        localLevel: _localLevelController.text.trim(), // Now using string from text field
        unitsRequired: int.parse(_weightController.text.trim()),
        requiredDate: formattedDate,
        requiredTime: formattedTime,
        caseDescription: _caseController.text.trim().isEmpty ? null : _caseController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        _showSuccessDialog(result.bloodRequest?.id);
      } else {
        _showErrorDialog(result.errorMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to create blood request: ${e.toString()}');
    }
  }

  void _showSuccessDialog(int? requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              "Blood Request Created!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            const Text(
              "Your blood request has been successfully created.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Request ID
            Text(
              "Request ID: #$requestId",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // Go to Home Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                "Go to Home",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error, color: Colors.red, size: 48),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              "Submission Failed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage ?? 'Failed to create blood request',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                "Close",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedBloodGroup,
            isExpanded: true,
            hint: Text(
              "Blood Group",
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade900),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            items: _bloodGroups.map((bg) {
              return DropdownMenuItem<String>(
                value: bg.id,
                child: Text(bg.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedBloodGroup = value),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            hint: Text(
              "Gender",
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade900),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            items: _genders.map((g) {
              return DropdownMenuItem<String>(
                value: g.id,
                child: Text(g.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedProvince,
            isExpanded: true,
            hint: Text(
              "Select Province",
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade900),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            items: _provinces.map((p) {
              return DropdownMenuItem<String>(
                value: p.id,
                child: Text(p.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedProvince = value;
                  _selectedDistrict = null;
                  _districts = [];
                });
                // Load districts filtered by selected province
                _loadDistricts(value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedDistrict,
            isExpanded: true,
            hint: Text(
              _selectedProvince == null
                  ? "Select province first ↑"
                  : "Select district ($_selectedProvince)",
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade900),
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            items: _districts.map((d) {
              return DropdownMenuItem<String>(
                value: d.id,
                child: Text(
                  d.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: _selectedProvince == null
                ? null  // Disable when no province selected
                : (value) {
                    setState(() => _selectedDistrict = value);
                  },
          ),
        ),
      ),
    );
  }
}
