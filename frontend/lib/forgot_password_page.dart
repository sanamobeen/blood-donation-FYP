import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api_config.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  final String _selectedLanguage = 'en';

  // Production mode - set to false for production
  static const bool _isDevelopmentMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      try {
        // Make API call to backend
        final response = await http.post(
          Uri.parse(ApiConfig.forgotPasswordEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim().toLowerCase(),
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        setState(() {
          _isSending = false;
        });

        // Parse response
        final responseData = jsonDecode(response.body);

        // Check if request was successful
        if (responseData['success'] == true) {
          if (mounted) {
            if (_isDevelopmentMode) {
              // Development mode: Extract token and show testing options
              final String? token = responseData['data']?['token'];

              // Development mode: Show dialog with testing options
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(
                    _selectedLanguage == 'ur' ? 'ای میل بھیج دیا گیا' : 'Email Sent',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLanguage == 'ur'
                            ? 'پاسورڈ ری سیٹ لنک آپ کے ای میل پر بھیج دیا گیا ہے۔'
                            : 'Password reset link has been sent to your email.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedLanguage == 'ur'
                            ? 'ڈویلپمنٹ موڈ:'
                            : 'Development Mode:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLanguage == 'ur'
                            ? 'ٹیسٹ کرنے کے لیے نیچے بٹن دبائیں'
                            : 'Click "Test Now" to test the reset flow',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _emailController.clear();
                      },
                      child: Text(_selectedLanguage == 'ur' ? 'بند کریں' : 'Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(
                              email: _emailController.text.trim(),
                              token: token,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                      ),
                      child: Text(_selectedLanguage == 'ur' ? 'ٹیسٹ اب کریں' : 'Test Now'),
                    ),
                  ],
                ),
              );
            } else {
              // Production mode: Clear email and show simple success message
              _emailController.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _selectedLanguage == 'ur'
                        ? 'پاسورڈ ری سیٹ لنک آپ کے ای میل پر بھیج دیا گیا ہے۔ براہ کرم اپنے ای میل کو چیک کریں'
                        : 'Password reset link has been sent to your email. Please check your email to reset your password.',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          // Email doesn't exist or other error - show error message
          String errorMessage = _selectedLanguage == 'ur'
              ? 'کوئی مسئلہ پیش آگیا'
              : 'An error occurred';

          // Extract error message from response
          if (responseData['errors'] != null) {
            if (responseData['errors']['email'] != null) {
              errorMessage = responseData['errors']['email'][0];
            } else if (responseData['message'] != null) {
              errorMessage = responseData['message'];
            }
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
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
      } catch (e) {
        setState(() {
          _isSending = false;
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
          _selectedLanguage == 'ur' ? 'پاسورڈ بھول گئے' : 'Forgot Password',
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
                    Icons.lock_reset,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  _selectedLanguage == 'ur' ? 'پاسورڈ دوبارہ سیٹ کریں' : 'Reset Your Password',
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
                        ? 'اپنا ای میل درج کریں۔ ہم آپ کو پاسورڈ دوبارہ سیٹ کرنے کا لنک بھیج دیں گے۔'
                        : 'Enter your email address and we\'ll send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Email Field
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
                  hintText: _selectedLanguage == 'ur' ? 'ای میل درج کریں' : 'Enter your email',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedLanguage == 'ur'
                        ? 'براہ کرم ای میل درج کریں'
                        : 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return _selectedLanguage == 'ur'
                        ? 'درست ای میل درج کریں'
                        : 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Send Link Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _selectedLanguage == 'ur' ? 'لنک بھیجیں' : 'Send Link',
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
                  onPressed: () => Navigator.pop(context),
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
