import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/language_service.dart';
import 'utils/mock_data.dart';
import 'config/api_config.dart';
import 'landing_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _localLevelController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Selected values
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  String _selectedProvince = 'Punjab';
  String _selectedDistrict = 'Lahore';  // First district in Punjab
  bool _agreeToTerms = false;
  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Field-specific error messages
  Map<String, String> _fieldErrors = {};

  final _formKey = GlobalKey<FormState>();
  // Individual form keys for each step validation
  final _personalInfoKey = GlobalKey<FormState>();
  final _contactInfoKey = GlobalKey<FormState>();
  final _confirmationKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _localLevelController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return AppTranslations.getText(key, _selectedLanguage);
  }

  // Clear error for a specific field when user starts typing
  void _clearFieldError(String fieldName) {
    if (_fieldErrors.containsKey(fieldName)) {
      setState(() {
        _fieldErrors.remove(fieldName);
      });
    }
  }

  // Get error message for a specific field
  String? _getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  // Check if a field has an error
  bool _hasFieldError(String fieldName) {
    return _fieldErrors.containsKey(fieldName);
  }

  // Validate password matching in real-time
  String? _validatePasswordMatching(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return null;
    }
    if (_passwordController.text.isNotEmpty && confirmPassword != _passwordController.text) {
      return _selectedLanguage == 'ur' ? 'پاسورڈز مطابقت نہیں رکھتے' : 'Passwords do not match';
    }
    return null;
  }

  void _register() async {
    // Clear previous errors
    setState(() {
      _fieldErrors = {};
    });

    if (!_agreeToTerms) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedLanguage == 'ur' ? 'براہ کرم شرائط و ضوابط سے متفق ہوں' : 'Please agree to terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate form before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      // Convert date format from DD/MM/YYYY to YYYY-MM-DD
      String formatDate(String date) {
        if (date.isEmpty) return '';
        var parts = date.split('/');
        if (parts.length != 3) return date;
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }

      // Prepare registration data
      final registrationData = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'local_level': _localLevelController.text.trim(),
        'date_of_birth': formatDate(_dobController.text),
        'blood_group': _selectedBloodGroup,
        'password': _passwordController.text,
        'confirm_password': _confirmPasswordController.text,
      };

      debugPrint('Registration data: $registrationData');

      // Make API call to backend
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      ).timeout(
        ApiConfig.connectTimeout,
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Store JWT tokens for future requests
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseData['data']['tokens']['access']);
        await prefs.setString('refresh_token', responseData['data']['tokens']['refresh']);
        await prefs.setString('user_email', responseData['data']['user']['email']);
        await prefs.setString('user_name', responseData['data']['user']['full_name'] ?? 'User');
        await prefs.setBool('is_logged_in', true);

        // Get user data before async operations
        final userName = responseData['data']['user']['full_name'] ?? 'User';
        final selectedLanguage = _selectedLanguage;

        if (mounted) {
          setState(() {
            _isRegistering = false;
          });

          // Show success message with user data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(selectedLanguage == 'ur' ? 'رجسٹریشن کامیاب!' : 'Registration successful! Welcome, $userName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to landing page and clear all navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('Error data: $errorData');

        if (mounted) {
          setState(() {
            _isRegistering = false;
          });

          // Show simple error message
          String errorMessage = _selectedLanguage == 'ur'
              ? 'رجسٹریشن ناکام ہوئی'
              : 'Registration failed';

          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('errors')) {
            // If field errors exist, just show first error
            final errors = errorData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError[0].toString();
              }
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: _selectedLanguage == 'ur' ? 'ٹھیک ہے' : 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');

      if (mounted) {
        setState(() {
          _isRegistering = false;
        });

        // Show appropriate error message based on exception type
        String errorMessage = _selectedLanguage == 'ur' ? 'رجسٹریشن ناکام ہوئی' : 'Registration failed';

        if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
          errorMessage = _selectedLanguage == 'ur' ? 'طلب وقت ختم ہوگیا' : 'Request timeout. Please try again.';
        } else if (e.toString().contains('Connection') || e.toString().contains('Network')) {
          errorMessage = _selectedLanguage == 'ur' ? 'نیٹ ورک کا مسئلہ' : 'Network error. Please check your connection.';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = _selectedLanguage == 'ur' ? 'سرور سے نہیں جڑ سکتا' : 'Cannot connect to server. Please check if backend is running.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: _selectedLanguage == 'ur' ? 'ٹھیک ہے' : 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  int _currentStep = 1;

  void _nextStep() {
    // Validate current step before proceeding
    bool isValid = false;

    switch (_currentStep) {
      case 1:
        isValid = _validatePersonalInfo();
        break;
      case 2:
        isValid = _validateContactInfo();
        break;
      case 3:
        // Step 3 (Confirmation) - submit form, no next step
        return;
    }

    if (isValid && _currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Validate Personal Information card
  bool _validatePersonalInfo() {
    bool isValid = true;
    List<String> errors = [];

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      errors.add(_selectedLanguage == 'ur' ? 'نام درج کریں' : 'Please enter your name');
      isValid = false;
    }

    // Validate gender (has default value, so always valid)
    // Validate blood group (has default value, so always valid)

    // Validate date of birth
    if (_dobController.text.trim().isEmpty) {
      errors.add(_selectedLanguage == 'ur' ? 'تاریخ پیدائش منتخب کریں' : 'Please select date of birth');
      isValid = false;
    }

    if (!isValid) {
      _showValidationError(errors.first);
    }

    return isValid;
  }

  // Validate Contact Information card
  bool _validateContactInfo() {
    bool isValid = true;
    List<String> errors = [];

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      errors.add(_selectedLanguage == 'ur' ? 'ای میل درج کریں' : 'Please enter your email');
      isValid = false;
    } else if (!_emailController.text.contains('@')) {
      errors.add(_selectedLanguage == 'ur' ? 'درست ای میل درج کریں' : 'Please enter a valid email');
      isValid = false;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      errors.add(_selectedLanguage == 'ur' ? 'فون نمبر درج کریں' : 'Please enter your phone number');
      isValid = false;
    }

    // Validate province (has default, so always valid)
    // Validate district (has default, so always valid)

    // Validate local level
    if (_localLevelController.text.trim().isEmpty) {
      errors.add(_selectedLanguage == 'ur' ? 'مقامی سطح درج کریں' : 'Please enter local level');
      isValid = false;
    }

    if (!isValid) {
      _showValidationError(errors.first);
    }

    return isValid;
  }

  // Show validation error message
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: _selectedLanguage == 'ur' ? 'ٹھیک ہے' : 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _translate('register_as_donor'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedLanguage == 'ur' ? 'رجسٹر کریں اور زندگیاں بچائیں' : 'Register and Save Lives',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedLanguage == 'ur' ? 'خون کا عطیہ کریں، ہیرو بنیں' : 'Donate blood, be a hero',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step Indicator
              _buildStepIndicator(isDark),
              const SizedBox(height: 24),

              // Cards based on current step
              if (_currentStep == 1) _buildPersonalInfoCard(isDark),
              if (_currentStep == 2) _buildContactInfoCard(isDark),
              if (_currentStep == 3) _buildConfirmationCard(isDark),

              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(isDark),

              const SizedBox(height: 16),

              // Login Link
              Center(
                child: Wrap(
                  children: [
                    Text(
                      _selectedLanguage == 'ur' ? 'پہلے سے اکاؤنٹ ہے؟ ' : 'Already have an account? ',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        _selectedLanguage == 'ur' ? 'لاگ ان کریں' : 'Login',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, isDark),
        Container(
          width: 50,
          height: 2,
          color: _currentStep >= 2 ? Colors.red.shade900 : Colors.grey.shade300,
        ),
        _buildStepCircle(2, isDark),
        Container(
          width: 50,
          height: 2,
          color: _currentStep >= 3 ? Colors.red.shade900 : Colors.grey.shade300,
        ),
        _buildStepCircle(3, isDark),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isDark) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted ? Colors.red.shade900 : Colors.grey.shade300,
        border: Border.all(
          color: isActive || isCompleted ? Colors.red.shade900 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isDark) {
    return Form(
      key: _personalInfoKey,
      child: _buildCard(
        isDark,
        title: _selectedLanguage == 'ur' ? 'ذاتی معلومات' : 'Personal Information',
        icon: Icons.person,
        children: [
          // Full Name
          TextFormField(
            controller: _nameController,
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

        // Gender
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'جنس' : 'Gender',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.person_outline, color: Colors.red.shade900),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedGender = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Blood Group
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
          items: MockDonorData.getBloodGroups().map((group) {
            return DropdownMenuItem(
              value: group,
              child: Text(group),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedBloodGroup = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Date of Birth
        TextFormField(
          controller: _dobController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'تاریخ پیدائش' : 'Date of Birth',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.calendar_today, color: Colors.red.shade900),
            hintText: _selectedLanguage == 'ur' ? 'تاریخ منتخب کریں' : 'Select Date',
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null && mounted) {
              setState(() {
                _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم تاریخ پیدائش درج کریں' : 'Please enter your date of birth';
            }
            return null;
          },
        ),
      ],
    ),
  );
}

  Widget _buildContactInfoCard(bool isDark) {
    return Form(
      key: _contactInfoKey,
      child: _buildCard(
        isDark,
        title: _selectedLanguage == 'ur' ? 'رابطہ کی معلومات' : 'Contact Information',
        icon: Icons.contact_phone,
        children: [
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
          items: MockDonorData.getProvinces().map((province) {
            return DropdownMenuItem(
              value: province,
              child: Text(_translate(province.toLowerCase())),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedProvince = value;
                _selectedDistrict = MockDonorData.getDistricts(value).first;
              });
            }
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
          items: MockDonorData.getDistricts(_selectedProvince).map((district) {
            return DropdownMenuItem(
              value: district,
              child: Text(district),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDistrict = value;
              });
            }
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
            prefixIcon: Icon(Icons.location_on, color: Colors.red.shade900),
            hintText: _selectedLanguage == 'ur' ? 'مثلاً: جی-7 مارکیز' : 'e.g., G-7 Markaz',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم مقامی سطح درج کریں' : 'Please enter your local level';
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
              return _selectedLanguage == 'ur' ? 'براہ کرم ای میل درج کریں' : 'Please enter your email';
            }
            if (!value.contains('@')) {
              return _selectedLanguage == 'ur' ? 'درست ای میل درج کریں' : 'Please enter a valid email';
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
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.phone, color: Colors.red.shade900),
            hintText: '+92-XXX-XXXXXXX',
            errorText: _getFieldError('phone'),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _hasFieldError('phone') ? Colors.red : Colors.grey.shade900, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onChanged: (value) {
            _clearFieldError('phone');
          },
          validator: (value) {
            // Check backend error first
            if (_hasFieldError('phone')) {
              return _getFieldError('phone');
            }

            // Then check client-side validation
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم فون نمبر درج کریں' : 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'پاسورڈ' : 'Password',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.red.shade900),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.red.shade900,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            errorText: _getFieldError('password'),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _hasFieldError('password') ? Colors.red : Colors.grey.shade900, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onChanged: (value) {
            _clearFieldError('password');
            // Clear confirm password error when password changes
            if (_confirmPasswordController.text.isNotEmpty) {
              _clearFieldError('confirm_password');
              // Force rebuild to update confirm password validation
              setState(() {});
            }
          },
          validator: (value) {
            // Check backend error first
            if (_hasFieldError('password')) {
              return _getFieldError('password');
            }

            // Then check client-side validation
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ درج کریں' : 'Please enter your password';
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
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: _selectedLanguage == 'ur' ? 'پاسورڈ تصدیق کریں' : 'Confirm Password',
            labelStyle: TextStyle(color: Colors.red.shade900),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade900, width: 2),
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.red.shade900),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confirmPasswordController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _confirmPasswordController.text == _passwordController.text &&
                    !_hasFieldError('confirm_password'))
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.red.shade900,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ],
            ),
            errorText: _getFieldError('confirm_password') ?? _validatePasswordMatching(_confirmPasswordController.text),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: (_hasFieldError('confirm_password') || _validatePasswordMatching(_confirmPasswordController.text) != null) ? Colors.red : Colors.grey.shade900, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            // Show helper text when passwords don't match
            helperText: _confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text != _passwordController.text
                        ? (_selectedLanguage == 'ur' ? 'پاسورڈز مماثل نہیں ہیں' : 'Passwords do not match')
                        : null,
            helperStyle: TextStyle(color: Colors.red),
          ),
          onChanged: (value) {
            _clearFieldError('confirm_password');
            // Trigger revalidation to show password matching error immediately
            setState(() {}); // Force rebuild to show/hide password matching error
          },
          validator: (value) {
            // Check backend error first
            if (_hasFieldError('confirm_password')) {
              return _getFieldError('confirm_password');
            }

            // Check password matching first
            final passwordMatchError = _validatePasswordMatching(value);
            if (passwordMatchError != null) {
              return passwordMatchError;
            }

            // Then check client-side validation
            if (value == null || value.trim().isEmpty) {
              return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ دوبارہ درج کریں' : 'Please confirm your password';
            }
            return null;
          },
        ),
      ],
    ),
  );
}

  Widget _buildConfirmationCard(bool isDark) {
    return Form(
      key: _confirmationKey,
      child: _buildCard(
        isDark,
        title: _selectedLanguage == 'ur' ? 'تصدیق' : 'Confirmation',
        icon: Icons.check_circle,
        children: [
        // Summary Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedLanguage == 'ur' ? 'رجسٹریشن کا خلاصہ' : 'Registration Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'نام' : 'Name', _nameController.text),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'جنس' : 'Gender', _selectedGender),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'بلڈ گروپ' : 'Blood Group', _selectedBloodGroup),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'تاریخ پیدائش' : 'Date of Birth', _dobController.text),
              const SizedBox(height: 8),
              Text(
                _selectedLanguage == 'ur' ? 'رابطہ کی معلومات:' : 'Contact Information:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'صوبہ' : 'Province', _translate(_selectedProvince.toLowerCase())),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'ضلع' : 'District', _selectedDistrict),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'مقامی سطح' : 'Local Level', _localLevelController.text),
              _buildSummaryRow('Email', _emailController.text),
              _buildSummaryRow(_selectedLanguage == 'ur' ? 'فون' : 'Phone', _phoneController.text),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Terms and Conditions
        Row(
          children: [
            Checkbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value!;
                });
              },
              activeColor: Colors.red.shade900,
            ),
            Expanded(
              child: Wrap(
                children: [
                  Text(
                    _selectedLanguage == 'ur' ? 'میں ' : 'I agree to the ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show terms dialog
                    },
                    child: Text(
                      _selectedLanguage == 'ur' ? 'شرائط و ضوابط' : 'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
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
  );
}

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.red.shade900, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Card Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Row(
      children: [
        // Previous Button
        if (_currentStep > 1)
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedLanguage == 'ur' ? 'پچھلا' : 'Previous',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        if (_currentStep > 1) const SizedBox(width: 16),

        // Next/Submit Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? (_isRegistering ? null : _register) : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isRegistering && _currentStep == 3
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 3
                          ? (_selectedLanguage == 'ur' ? 'جمع کروائیں' : 'Submit')
                          : (_selectedLanguage == 'ur' ? 'اگلا' : 'Next'),
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
