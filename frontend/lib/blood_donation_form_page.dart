import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing_page.dart';

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
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Selection State Variables
  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _lastDonationDate;
  TimeOfDay? _selectedTime;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocalLevel;

  // Data Lists
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Location Lists
  final List<String> _provinces = [
    'Province 1', 'Province 2', 'Province 3', 'Province 4', 'Province 5',
    'Province 6', 'Province 7', 'Province 8', 'Province 9', 'Province 10',
  ];
  final List<String> _districts = [
    'District 1', 'District 2', 'District 3', 'District 4', 'District 5',
    'District 6', 'District 7', 'District 8', 'District 9', 'District 10',
  ];
  final List<String> _localLevels = [
    'Local Level 1', 'Local Level 2', 'Local Level 3', 'Local Level 4', 'Local Level 5',
    'Local Level 6', 'Local Level 7', 'Local Level 8', 'Local Level 9', 'Local Level 10',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _caseController.dispose();
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
      body: SingleChildScrollView(
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
              _buildDropdownField(
                isDark,
                "Blood Group",
                Icons.bloodtype,
                _selectedBloodType,
                _bloodTypes,
                (value) => setState(() => _selectedBloodType = value),
                validator: (value) =>
                    value == null ? "Please select your blood group" : null,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                isDark,
                "Gender",
                Icons.wc,
                _selectedGender,
                _genders,
                (value) => setState(() => _selectedGender = value),
                validator: (value) =>
                    value == null ? "Please select your gender" : null,
              ),
              const SizedBox(height: 24),

              // Location Details Section
              _buildSectionHeader(isDark, "Location Details", Icons.location_on),
              const SizedBox(height: 16),
              _buildDropdownField(
                isDark,
                "Select Provinces",
                Icons.location_city,
                _selectedProvince,
                _provinces,
                (value) => setState(() => _selectedProvince = value),
                validator: (value) =>
                    value == null ? "Please select your province" : null,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                isDark,
                "Select District",
                Icons.place,
                _selectedDistrict,
                _districts,
                (value) => setState(() => _selectedDistrict = value),
                validator: (value) =>
                    value == null ? "Please select your district" : null,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                isDark,
                "Select Local Level",
                Icons.apartment,
                _selectedLocalLevel,
                _localLevels,
                (value) => setState(() => _selectedLocalLevel = value),
                validator: (value) =>
                    value == null ? "Please select your local level" : null,
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

  Widget _buildDropdownField(
    bool isDark,
    String label,
    IconData icon,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
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
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(icon, color: Colors.red.shade900),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
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

  void _submitForm() {
    // Step 1: Form Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Step 2: Submit to Backend
 
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    // Generate Donor ID from timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final donorId = 'BD${timestamp.toString().substring(7)}';
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
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
              "Registration Successful!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            const Text(
              "Thank you for registering as a blood donor. Your information has been saved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Donor ID
            Text(
              "Appointment ID: $donorId",
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
}
