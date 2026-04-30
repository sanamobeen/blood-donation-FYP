import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'config/api_config.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String? token;

  const ResetPasswordPage({
    super.key,
    required this.email,
    this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isResetting = false;
  final String _selectedLanguage = 'en';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isResetting = true;
      });

      try {
        // Make API call to backend
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/accounts/reset-password/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.email.trim().toLowerCase(),
            'token': widget.token,
            'new_password': _newPasswordController.text,
            'confirm_password': _confirmPasswordController.text,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        setState(() {
          _isResetting = false;
        });

        // Show success message and navigate to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedLanguage == 'ur'
                    ? 'پاسورڈ کامیابی سے دوبارہ سیٹ ہو گیا'
                    : 'Password reset successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to login page and clear all routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _isResetting = false;
        });

        String errorMessage = _selectedLanguage == 'ur'
            ? 'کوئی مسئلہ پیش آگیا'
            : 'An error occurred';

        if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
          errorMessage = _selectedLanguage == 'ur'
              ? 'سرور سے نہیں جا سکتا'
              : 'Cannot connect to server';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = _selectedLanguage == 'ur'
              ? 'انٹرنیٹ کنکشن نہیں'
              : 'No internet connection';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
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
          _selectedLanguage == 'ur' ? 'پاسورڈ دوبارہ سیٹ کریں' : 'Reset Password',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.password,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  _selectedLanguage == 'ur' ? 'نیا پاسورڈ سیٹ کریں' : 'Set New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _selectedLanguage == 'ur'
                        ? 'براہ کرم اپنا نیا پاسورڈ درج کریں۔'
                        : 'Please enter your new password below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Email Display (read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.red.shade900),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLanguage == 'ur' ? 'ای میل' : 'Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'ur' ? 'نیا پاسورڈ' : 'New Password',
                  labelStyle: TextStyle(color: Colors.red.shade900),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.red.shade900),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.red.shade900,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                  hintText: _selectedLanguage == 'ur' ? 'نیا پاسورڈ درج کریں' : 'Enter new password',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedLanguage == 'ur'
                        ? 'براہ کرم نیا پاسورڈ درج کریں'
                        : 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return _selectedLanguage == 'ur'
                        ? 'پاسورڈ کم از کم 6 حروف کا ہونا چاہیے'
                        : 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'ur' ? 'پاسورڈ کی تصدیق کریں' : 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.red.shade900),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.red.shade900),
                  suffixIcon: IconButton(
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
                  hintText: _selectedLanguage == 'ur' ? 'پاسورڈ دوبارہ درج کریں' : 'Confirm new password',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedLanguage == 'ur'
                        ? 'براہ کرم پاسورڈ کی تصدیق کریں'
                        : 'Please confirm your password';
                  }
                  if (value != _newPasswordController.text) {
                    return _selectedLanguage == 'ur'
                        ? 'پاسورڈز مماثل نہیں ہیں'
                        : 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isResetting ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResetting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _selectedLanguage == 'ur' ? 'پاسورڈ دوبارہ سیٹ کریں' : 'Reset Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Login Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    _selectedLanguage == 'ur' ? 'واپس لاگ ان پر جائیں' : 'Back to Login',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
