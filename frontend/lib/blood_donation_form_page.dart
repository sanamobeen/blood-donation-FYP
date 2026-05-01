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

  // Selection State Variables (IDs for API)
  int? _selectedGenderId;
  int? _selectedBloodGroupId;
  DateTime? _lastDonationDate;
  TimeOfDay? _selectedTime;
  int? _selectedProvinceId;
  int? _selectedDistrictId;
  int? _selectedLocalLevelId;

  // API Data Lists
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<LocalLevel> _localLevels = [];
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
      if (provincesResult.success && provincesResult.provinces != null) {
        setState(() {
          _provinces = provincesResult.provinces!;
        });
      }

      // Load blood groups
      final bloodGroupsResult = await BloodRequestService.getBloodGroups();
      if (bloodGroupsResult.success && bloodGroupsResult.bloodGroups != null) {
        setState(() {
          _bloodGroups = bloodGroupsResult.bloodGroups!;
        });
      }

      // Load genders
      final gendersResult = await BloodRequestService.getGenders();
      if (gendersResult.success && gendersResult.genders != null) {
        setState(() {
          _genders = gendersResult.genders!;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadDistricts(int provinceId) async {
    final result = await BloodRequestService.getDistricts(provinceId);
    if (result.success && result.districts != null) {
      setState(() {
        _districts = result.districts!;
        _selectedLocalLevelId = null;
        _localLevels = [];
      });
    }
  }

  Future<void> _loadLocalLevels(int districtId) async {
    final result = await BloodRequestService.getLocalLevels(districtId);
    if (result.success && result.localLevels != null) {
      setState(() {
        _localLevels = result.localLevels!;
      });
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
                "Contact Person",
                Icons.contact_phone,
                _contactPersonController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter contact person";
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
              _buildLocalLevelDropdown(isDark),
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
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
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
              ? '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}'
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
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            onTimeSelected(picked);
          }
        },
      ),
    );
  }

  void _submitForm() async {
    // Step 1: Form Validation
    if (!_formKey.currentState!.validate()) {
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
        bloodGroup: _selectedBloodGroupId!,
        gender: _selectedGenderId!,
        province: _selectedProvinceId!,
        district: _selectedDistrictId!,
        localLevel: _selectedLocalLevelId!,
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
      child: DropdownButtonFormField<int>(
        initialValue: _selectedBloodGroupId,
        decoration: InputDecoration(
          labelText: "Blood Group",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.bloodtype, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: _bloodGroups.map((bg) {
          return DropdownMenuItem<int>(
            value: bg.id,
            child: Text(bg.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedBloodGroupId = value),
        validator: (value) =>
            value == null ? "Please select your blood group" : null,
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
      child: DropdownButtonFormField<int>(
        initialValue: _selectedGenderId,
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.wc, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: _genders.map((g) {
          return DropdownMenuItem<int>(
            value: g.id,
            child: Text(g.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedGenderId = value),
        validator: (value) =>
            value == null ? "Please select your gender" : null,
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
      child: DropdownButtonFormField<int>(
        initialValue: _selectedProvinceId,
        decoration: InputDecoration(
          labelText: "Select Province",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.location_city, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: _provinces.map((p) {
          return DropdownMenuItem<int>(
            value: p.id,
            child: Text(p.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedProvinceId = value;
              _selectedDistrictId = null;
              _districts = [];
            });
            _loadDistricts(value);
          }
        },
        validator: (value) =>
            value == null ? "Please select your province" : null,
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
      child: DropdownButtonFormField<int>(
        initialValue: _selectedDistrictId,
        decoration: InputDecoration(
          labelText: "Select District",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.place, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: _districts.map((d) {
          return DropdownMenuItem<int>(
            value: d.id,
            child: Text(d.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedDistrictId = value;
              _selectedLocalLevelId = null;
              _localLevels = [];
            });
            _loadLocalLevels(value);
          }
        },
        validator: (value) =>
            value == null ? "Please select your district" : null,
      ),
    );
  }

  Widget _buildLocalLevelDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedLocalLevelId,
        decoration: InputDecoration(
          labelText: "Select Local Level",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.apartment, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: _localLevels.map((ll) {
          return DropdownMenuItem<int>(
            value: ll.id,
            child: Text(ll.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedLocalLevelId = value),
        validator: (value) =>
            value == null ? "Please select your local level" : null,
      ),
    );
  }
}
