import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api_config.dart';
import 'landing_page.dart';
import 'services/language_service.dart';

class UnifiedRegistrationPage extends StatefulWidget {
  const UnifiedRegistrationPage({super.key});

  @override
  State<UnifiedRegistrationPage> createState() => _UnifiedRegistrationPageState();
}

class _UnifiedRegistrationPageState extends State<UnifiedRegistrationPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  // Stepper state
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Phone & OTP (OTP DISABLED)
  final _phoneController = TextEditingController();
  // final _otpController = TextEditingController();  // Commented out - OTP disabled
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // bool _isOtpSent = false;  // Commented out - OTP disabled
  bool _isOtpVerified = false;  // Still used for state management
  // bool _isSendingOtp = false;  // Commented out - OTP disabled
  bool _isRegistering = false;

  // Step 2: Role Selection
  // ignore: prefer_final_fields
  List<String> _selectedRoles = [];
  String? _selectedBloodGroup;

  // Step 3: Basic Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedProvince = 'Punjab';
  String _selectedDistrict = 'Lahore';
  final _localLevelController = TextEditingController();

  // Form keys
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Blood groups
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Provinces and districts (sample)
  final Map<String, List<String>> _provinceDistricts = {
    'Punjab': ['Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala'],
    'Sindh': ['Karachi', 'Hyderabad', 'Sukkur', 'Larkana'],
    'Khyber Pakhtunkhwa': ['Peshawar', 'Mardan', 'Swabi', 'Abbottabad'],
    'Balochistan': ['Quetta', 'Gwadar', 'Turbat', 'Sibi'],
    'Islamabad Capital Territory': ['Islamabad'],
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    // _otpController.dispose();  // Commented out - OTP disabled
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _localLevelController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP (COMMENTED OUT - OTP DISABLED)
  // Future<void> _sendOTP() async {
  //   if (_phoneController.text.trim().isEmpty) {
  //     _showErrorSnackBar(_selectedLanguage == 'ur'
  //         ? 'براہ کرم فون نمبر درج کریں'
  //         : 'Please enter phone number');
  //     return;
  //   }
  //
  //   setState(() => _isSendingOtp = true);
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${ApiConfig.baseUrl}/api/accounts/otp/send/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'phone': _phoneController.text.trim(),
  //         'purpose': 'registration',
  //       }),
  //     ).timeout(const Duration(seconds: 30));
  //
  //     final data = jsonDecode(response.body);
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _isOtpSent = true;
  //         _isSendingOtp = false;
  //       });
  //
  //       _showSuccessSnackBar(_selectedLanguage == 'ur'
  //           ? 'OTP بھیجا گیا: ${data['data']['otp']}'
  //           : 'OTP sent: ${data['data']['otp']}');
  //
  //       // In production, OTP will be sent via SMS
  //       // For development, showing OTP in response
  //     } else {
  //       throw Exception(data['message'] ?? 'Failed to send OTP');
  //     }
  //   } catch (e) {
  //     setState(() => _isSendingOtp = false);
  //     _showErrorSnackBar(_selectedLanguage == 'ur'
  //         ? 'OTP بھیجنے میں ناکام'
  //         : 'Failed to send OTP');
  //   }
  // }

  // Step 1: Verify OTP and Create Account (OTP DISABLED)
  Future<void> _verifyOTPAndCreateAccount() async {
    if (!_formKeys[0].currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/register/step1/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneController.text.trim(),
          // 'otp': _otpController.text.trim(),  // Commented out - OTP disabled
          'password': _passwordController.text,
          'confirm_password': _confirmPasswordController.text,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Store tokens for step 2
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['data']['tokens']['access']);
        await prefs.setString('refresh_token', data['data']['tokens']['refresh']);

        setState(() {
          _isOtpVerified = true;
          _isRegistering = false;
          _currentStep = 1; // Move to step 2
        });

        _showSuccessSnackBar(_selectedLanguage == 'ur'
            ? 'اکاؤنٹ بن گیا! اپنے کردار منتخب کریں'
            : 'Account created! Choose your roles.');
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      _showErrorSnackBar(_selectedLanguage == 'ur'
          ? 'راجسٹریشن ناکام'
          : 'Registration failed');
    }
  }

  // Step 2: Complete Registration (Add Roles)
  Future<void> _completeRegistration() async {
    if (!_formKeys[1].currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final requestBody = <String, Object>{
        'roles': _selectedRoles,
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'local_level': _localLevelController.text.trim(),
      };

      // Add blood_group if donor role selected
      if (_selectedRoles.contains('donor') && _selectedBloodGroup != null) {
        requestBody['blood_group'] = _selectedBloodGroup!;
        requestBody['gender'] = 'Other'; // Will be updated later
        requestBody['date_of_birth'] = DateTime(1990, 1, 1).toIso8601String(); // Placeholder
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/register/step2/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store additional user data
        await prefs.setString('user_email', data['data']['user']['email']);
        await prefs.setString('user_name', data['data']['user']['full_name']);
        await prefs.setStringList('user_roles', List<String>.from(data['data']['user']['roles']));
        await prefs.setBool('is_logged_in', true);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        }
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      _showErrorSnackBar(_selectedLanguage == 'ur'
          ? 'راجسٹریشن مکمل کرنے میں ناکام'
          : 'Failed to complete registration');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedLanguage == 'ur' ? 'رجسٹر کریں' : 'Register',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKeys[_currentStep],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(isDark),

              const SizedBox(height: 32),

              // Step Content
              _currentStep == 0
                  ? _buildStep1(isDark)
                  : _currentStep == 1
                      ? _buildStep2(isDark)
                      : _buildStep3(isDark),

              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Column(
      children: [
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: (_currentStep + 1) / _totalSteps,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Step Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepLabel(0, _selectedLanguage == 'ur' ? 'فون' : 'Phone'),
            _buildStepLabel(1, _selectedLanguage == 'ur' ? 'کردار' : 'Roles'),
            _buildStepLabel(2, _selectedLanguage == 'ur' ? 'معلومات' : 'Info'),
          ],
        ),
      ],
    );
  }

  Widget _buildStepLabel(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.red.shade900
                    : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.red.shade900 : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Step 1: Phone & OTP
  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLanguage == 'ur' ? 'فون تصدیق' : 'Phone Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedLanguage == 'ur'
              ? 'اپنے فون نمبر کی تصدیق کریں'
              : 'Verify your phone number',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          enabled: !_isOtpVerified,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'فون نمبر' : 'Phone Number',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.phone, color: Colors.red.shade900),
            hintText: _selectedLanguage == 'ur' ? '+923001234567' : '+923001234567',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur'
                  ? 'براہ کرم فون نمبر درج کریں'
                  : 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Send OTP Button - COMMENTED OUT (OTP DISABLED)
        // if (!_isOtpVerified)
        //   SizedBox(
        //     width: double.infinity,
        //     height: 50,
        //     child: ElevatedButton(
        //       onPressed: _isSendingOtp ? null : _sendOTP,
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: _isOtpSent ? Colors.green : Colors.red.shade900,
        //         foregroundColor: Colors.white,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //       ),
        //       child: _isSendingOtp
        //           ? const SizedBox(
        //               height: 20,
        //               width: 20,
        //               child: CircularProgressIndicator(
        //                 strokeWidth: 2,
        //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //               ),
        //             )
        //           : Text(
        //               _isOtpSent
        //                   ? (_selectedLanguage == 'ur' ? 'دوبارہ OTP بھیجیں' : 'Resend OTP')
        //                   : (_selectedLanguage == 'ur' ? 'OTP بھیجیں' : 'Send OTP'),
        //               style: const TextStyle(
        //                 fontSize: 16,
        //                 fontWeight: FontWeight.bold,
        //               ),
        //             ),
        //     ),
        //   ),
        //
        // if (_isOtpSent && !_isOtpVerified) ...[
        //   const SizedBox(height: 16),
        //
        //   // OTP Input - COMMENTED OUT (OTP DISABLED)
          // TextFormField(
          //   controller: _otpController,
          //   keyboardType: TextInputType.number,
          //   maxLength: 6,
          //   decoration: InputDecoration(
          //     labelText: _selectedLanguage == 'ur' ? 'OTP درج کریں' : 'Enter OTP',
          //     labelStyle: TextStyle(color: Colors.red.shade900),
          //     border: const OutlineInputBorder(),
          //     focusedBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.red.shade900, width: 2),
          //     ),
          //     prefixIcon: Icon(Icons.lock, color: Colors.red.shade900),
          //     hintText: _selectedLanguage == 'ur' ? '6 ہندسے' : '6 digits',
          //   ),
          //   validator: (value) {
          //     if (value == null || value.trim().isEmpty) {
          //       return _selectedLanguage == 'ur' ? 'براہ کرم OTP درج کریں' : 'Please enter OTP';
          //     }
          //     if (value.length != 6) {
          //       return _selectedLanguage == 'ur' ? 'OTP 6 ہندسوں کا ہونا چاہیے' : 'OTP must be 6 digits';
          //     }
          //     return null;
          //   },
          // ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'پاسورڈ' : 'Password',
              labelStyle: TextStyle(color: Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.lock, color: Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ درج کریں' : 'Please enter password';
              }
              if (value.length < 8) {
                return _selectedLanguage == 'ur' ? 'پاسورڈ کم از کم 8 حروف کا ہونا چاہیے' : 'Password must be at least 8 characters';
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
              labelText: _selectedLanguage == 'ur' ? 'پاسورڈ تصدیق کریں' : 'Confirm Password',
              labelStyle: TextStyle(color: Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.red.shade900),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ درج کریں' : 'Please confirm password';
              }
              if (value != _passwordController.text) {
                return _selectedLanguage == 'ur' ? 'پاسورڈ مماثل نہیں ہے' : 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
        // ],  # Commented out - was closing spread operator for OTP section
    );
  }

  // Step 2: Role Selection
  Widget _buildStep2(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLanguage == 'ur' ? 'اپنے کردار منتخب کریں' : 'Choose Your Roles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedLanguage == 'ur'
              ? 'آپ ایک سے زیادہ کردار منتخب کر سکتے ہیں'
              : 'You can select multiple roles',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Donor Role
        CheckboxListTile(
          value: _selectedRoles.contains('donor'),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedRoles.add('donor');
              } else {
                _selectedRoles.remove('donor');
                _selectedBloodGroup = null;
              }
            });
          },
          title: Row(
            children: [
              const Icon(Icons.handshake, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '🤝 Donor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedRoles.contains('donor')
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _selectedRoles.contains('donor')
                      ? Colors.blue.shade700
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.blue.shade700,
        ),

        // Patient Role
        CheckboxListTile(
          value: _selectedRoles.contains('patient'),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedRoles.add('patient');
              } else {
                _selectedRoles.remove('patient');
              }
            });
          },
          title: Row(
            children: [
              const Icon(Icons.volunteer_activism, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                '🩺 Patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedRoles.contains('patient')
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _selectedRoles.contains('patient')
                      ? Colors.red.shade700
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.red.shade700,
        ),

        // Blood Group (if Donor selected)
        if (_selectedRoles.contains('donor')) ...[
          const SizedBox(height: 16),
          Text(
            _selectedLanguage == 'ur' ? 'بلڈ گروپ (ضروری)' : 'Blood Group (Required)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedBloodGroup,
            decoration: InputDecoration(
              labelText: _selectedLanguage == 'ur' ? 'بلڈ گروپ' : 'Blood Group',
              labelStyle: TextStyle(color: Colors.red.shade900),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              prefixIcon: Icon(Icons.bloodtype, color: Colors.red.shade900),
            ),
            items: _bloodGroups
                .map((group) => DropdownMenuItem(
                      value: group,
                      child: Text(group),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedBloodGroup = value);
            },
            validator: (value) {
              if (_selectedRoles.contains('donor') && value == null) {
                return _selectedLanguage == 'ur' ? 'براہ کرم بلڈ گروپ منتخب کریں' : 'Please select blood group';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // Step 3: Basic Information
  Widget _buildStep3(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLanguage == 'ur' ? 'بنیاتی معلومات' : 'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // Full Name
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'پورا نام' : 'Full Name',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.person, color: Colors.red.shade900),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم نام درج کریں' : 'Please enter your name';
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
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.email, color: Colors.red.shade900),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم ای میل درج کریں' : 'Please enter email';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.trim())) {
              return _selectedLanguage == 'ur' ? 'درست ای میل درج کریں' : 'Please enter valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Province
        DropdownButtonFormField<String>(
          initialValue: _selectedProvince,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'صوبہ' : 'Province',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.location_city, color: Colors.red.shade900),
          ),
          items: _provinceDistricts.keys
              .map((province) => DropdownMenuItem(
                    value: province,
                    child: Text(province),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedProvince = value!;
              _selectedDistrict = _provinceDistricts[value]!.first;
            });
          },
          validator: (value) {
            if (value == null) {
              return _selectedLanguage == 'ur' ? 'براہ کرم صوبہ منتخب کریں' : 'Please select province';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // District
        DropdownButtonFormField<String>(
          initialValue: _selectedDistrict,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'ضلع' : 'District',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.map, color: Colors.red.shade900),
          ),
          items: _provinceDistricts[_selectedProvince]!
              .map((district) => DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedDistrict = value!);
          },
          validator: (value) {
            if (value == null) {
              return _selectedLanguage == 'ur' ? 'براہ کرم ضلع منتخب کریں' : 'Please select district';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Local Level
        TextFormField(
          controller: _localLevelController,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'مقامی سطح' : 'Local Level',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.place, color: Colors.red.shade900),
          ),
          validator: (value) {
            // Optional field
            return null;
          },
        ),
      ],
    );
  }

  // Navigation Buttons
  Widget _buildNavigationButtons(bool isDark) {
    return Row(
      children: [
        // Back Button
        if (_currentStep > 0)
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade900,
                  side: BorderSide(color: Colors.red.shade900, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedLanguage == 'ur' ? 'پیچھے' : 'Back',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        if (_currentStep > 0) const SizedBox(width: 16),

        // Next/Complete Button
        Expanded(
          flex: _currentStep > 0 ? 1 : 2,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isRegistering
                  ? null
                  : () {
                      if (_currentStep == 0) {
                        _verifyOTPAndCreateAccount();
                      } else if (_currentStep == 1) {
                        if (_selectedRoles.isEmpty) {
                          _showErrorSnackBar(_selectedLanguage == 'ur'
                              ? 'براہ کرم کم از کم ایک کردار منتخب کریں'
                              : 'Please select at least one role');
                          return;
                        }
                        setState(() => _currentStep++);
                      } else {
                        _completeRegistration();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
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
                      _currentStep == 2
                          ? (_selectedLanguage == 'ur' ? 'مکمل کریں' : 'Complete')
                          : (_selectedLanguage == 'ur' ? 'آگے بڑھیں' : 'Next'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
