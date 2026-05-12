import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';
import 'config/api_config.dart';

class SimpleRegistrationPage extends StatefulWidget {
  final String initialRole; // 'donor' or 'patient'

  const SimpleRegistrationPage({super.key, required this.initialRole});

  @override
  State<SimpleRegistrationPage> createState() => _SimpleRegistrationPageState();
}

class _SimpleRegistrationPageState extends State<SimpleRegistrationPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  // Form controllers - Step 1 (Common fields)
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _localLevelController = TextEditingController();

  // Form controllers - Step 2 (Role-specific fields)
  final _bloodGroupController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  String _selectedProvince = 'Punjab';
  String _selectedDistrict = '';
  String _selectedBloodGroup = 'A+';

  bool _isRegistering = false;
  int _currentStep = 1; // 1 = Common fields, 2 = Role-specific fields

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _localLevelController.dispose();
    _bloodGroupController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _registerCommonFields() async {
    if (!_formKey1.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/register/common/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim().toLowerCase(),
          'password': _passwordController.text,
          'full_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'province': _selectedProvince,
          'district': _selectedDistrict,
          'local_level': _localLevelController.text.trim(),
          'role': widget.initialRole, // 'donor' or 'patient'
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final tokens = responseData['data']['tokens'];

        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', tokens['access']);
        await prefs.setString('refresh_token', tokens['refresh']);
        await prefs.setString('user_email', _emailController.text.trim().toLowerCase());
        await prefs.setString('user_name', _fullNameController.text.trim());
        await prefs.setStringList('user_roles', [widget.initialRole]);

        setState(() {
          _currentStep = 2;
          _isRegistering = false;
        });

        _showSuccessSnackBar(_selectedLanguage == 'ur' ? 'اکاؤنٹ بن گیا!' : 'Account created!');
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      _showErrorSnackBar(_selectedLanguage == 'ur' ? 'راجسٹریشن ناکام' : 'Registration failed');
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey2.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final Map<String, dynamic> roleSpecificData = {};

      if (widget.initialRole == 'donor') {
        roleSpecificData['blood_group'] = _selectedBloodGroup;
      } else {
        roleSpecificData['blood_type'] = _selectedBloodGroup;
        roleSpecificData['emergency_contact_name'] = _emergencyContactNameController.text.trim();
        roleSpecificData['emergency_contact_phone'] = _emergencyContactPhoneController.text.trim();
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/register/${widget.initialRole}/complete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(roleSpecificData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _showSuccessSnackBar(_selectedLanguage == 'ur' ? 'رجسٹریشن مکمل!' : 'Registration complete!');

        // Navigate to appropriate dashboard
        if (!mounted) return;

        if (widget.initialRole == 'donor') {
          Navigator.pushReplacementNamed(context, '/donor-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/patient-dashboard');
        }
      } else {
        throw Exception('Failed to complete registration');
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      _showErrorSnackBar(_selectedLanguage == 'ur' ? 'راجسٹریشن ناکام' : 'Registration failed');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonor = widget.initialRole == 'donor';

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDonor ? Colors.blue.shade900 : Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isDonor
              ? (_selectedLanguage == 'ur' ? 'دونر رجسٹر' : 'Donor Registration')
              : (_selectedLanguage == 'ur' ? 'پیشنٹ رجسٹر' : 'Patient Registration'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(isDonor),

            const SizedBox(height: 24),

            // Step 1: Common Registration Fields
            if (_currentStep == 1) _buildCommonFieldsForm(isDark, isDonor),

            // Step 2: Role-Specific Fields
            if (_currentStep == 2) _buildRoleSpecificFieldsForm(isDark, isDonor),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDonor) {
    return Column(
      children: [
        // Step 1 indicator
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: _currentStep >= 1 ? (isDonor ? Colors.blue.shade900 : Colors.red.shade900) : Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedLanguage == 'ur' ? 'مرحلہ 1: بنیادی معلومات' : 'Step 1: Basic Information',
          style: TextStyle(fontSize: 14, fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal),
        ),
        const SizedBox(height: 16),

        // Step 2 indicator
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: _currentStep >= 2 ? (isDonor ? Colors.blue.shade900 : Colors.red.shade900) : Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isDonor
              ? (_selectedLanguage == 'ur' ? 'مرحلہ 2: دونر کی تفصیلات' : 'Step 2: Donor Details')
              : (_selectedLanguage == 'ur' ? 'مرحلہ 2: پیشنٹ کی تفصیلات' : 'Step 2: Patient Details'),
          style: TextStyle(fontSize: 14, fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildCommonFieldsForm(bool isDark, bool isDonor) {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedLanguage == 'ur' ? 'بنیادی معلومات' : 'Basic Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),

          // Full Name
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'پورا نام' : 'Full Name',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.person, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم نام درج کریں' : 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'ای میل' : 'Email',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.email, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم ای میل درج کریں' : 'Please enter email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'فون نمبر' : 'Phone Number',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.phone, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم فون نمبر درج کریں' : 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'پاسورڈ' : 'Password',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.lock, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ درج کریں' : 'Please enter password';
              }
              if (value.length < 6) {
                return _selectedLanguage == 'ur' ? 'پاسورڈ کم از کم 6 حروف کا' : 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'پاسورڹ تصدیق کریں' : 'Confirm Password',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.lock_outline, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ تصدیق کریں' : 'Please confirm password';
              }
              if (value != _passwordController.text) {
                return _selectedLanguage == 'ur' ? 'پاسورڈز مماثل نہیں' : 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Province Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedProvince,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'صوبہ' : 'Province',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.location_city, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            items: const [
              DropdownMenuItem(value: 'Punjab', child: Text('Punjab')),
              DropdownMenuItem(value: 'Sindh', child: Text('Sindh')),
              DropdownMenuItem(value: 'Khyber Pakhtunkhwa', child: Text('Khyber Pakhtunkhwa')),
              DropdownMenuItem(value: 'Balochistan', child: Text('Balochistan')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedProvince = value ?? 'Punjab';
                _selectedDistrict = '';
              });
            },
          ),
          const SizedBox(height: 16),

          // District Input
          TextFormField(
            controller: _districtController,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'ضلع' : 'District',
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.location_on, color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم ضلع درج کریں' : 'Please enter district';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isRegistering ? null : _registerCommonFields,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDonor ? Colors.blue.shade900 : Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRegistering
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _selectedLanguage == 'ur' ? 'اگلے' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificFieldsForm(bool isDark, bool isDonor) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDonor
                ? (_selectedLanguage == 'ur' ? 'دونر کی تفصیلات' : 'Donor Details')
                : (_selectedLanguage == 'ur' ? 'پیشنٹ کی تفصیلات' : 'Patient Details'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),

          // Blood Group (Common for both but different purpose)
          DropdownButtonFormField<String>(
            initialValue: _selectedBloodGroup,
            decoration: InputDecoration(
              labelText: isDonor
                  ? (_selectedLanguage == 'ur' ? 'بلڈ گروپ' : 'Blood Group')
                  : (_selectedLanguage == 'ur' ? 'بلڈ ٹائپ' : 'Blood Type'),
              labelStyle: TextStyle(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDonor ? Colors.blue.shade900 : Colors.red.shade900, width: 2),
              ),
              prefixIcon: const Icon(Icons.bloodtype, color: Colors.red),
            ),
            items: const [
              DropdownMenuItem(value: 'A+', child: Text('A+')),
              DropdownMenuItem(value: 'A-', child: Text('A-')),
              DropdownMenuItem(value: 'B+', child: Text('B+')),
              DropdownMenuItem(value: 'B-', child: Text('B-')),
              DropdownMenuItem(value: 'AB+', child: Text('AB+')),
              DropdownMenuItem(value: 'AB-', child: Text('AB-')),
              DropdownMenuItem(value: 'O+', child: Text('O+')),
              DropdownMenuItem(value: 'O-', child: Text('O-')),
            ],
            onChanged: (value) {
              setState(() => _selectedBloodGroup = value ?? 'A+');
            },
          ),
          const SizedBox(height: 16),

          // Patient-specific fields
          if (!isDonor) ...[
            // Emergency Contact Name
            TextFormField(
              controller: _emergencyContactNameController,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'ur' ? 'ایمرجنسی کا نام' : 'Emergency Contact Name',
                labelStyle: TextStyle(color: Colors.red.shade900),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                ),
                prefixIcon: Icon(Icons.contact_phone, color: Colors.red.shade900),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _selectedLanguage == 'ur' ? 'براہ کرم نام درج کریں' : 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Emergency Contact Phone
            TextFormField(
              controller: _emergencyContactPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'ur' ? 'ایمرجنسی فون' : 'Emergency Contact Phone',
                labelStyle: TextStyle(color: Colors.red.shade900),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                ),
                prefixIcon: Icon(Icons.phone, color: Colors.red.shade900),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _selectedLanguage == 'ur' ? 'براہ کرم فون درج کریں' : 'Please enter phone';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],

          // Complete Registration Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isRegistering ? null : _completeRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDonor ? Colors.blue.shade900 : Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRegistering
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _selectedLanguage == 'ur' ? 'رجسٹر مکمل کریں' : 'Complete Registration',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
