import 'package:flutter/material.dart';
import 'register_page.dart';
import 'services/language_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoggingIn = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });

      // Simulate login
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedLanguage == 'ur' ? 'لاگ ان کامیاب!' : 'Login successful!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back or to home
        Navigator.pop(context);
      }
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedLanguage == 'ur' ? 'پاسورڈ بھول گئے؟' : 'Forgot Password?'),
        content: Text(
          _selectedLanguage == 'ur'
              ? 'براہ کرم اپنا ای میل درج کریں ہم آپ کو پاسورڈ دوبارہ سیٹ کرنے کا لنک بھیج دیں گے۔'
              : 'Please enter your email. We will send you a link to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_selectedLanguage == 'ur' ? 'منسوخ کریں' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_selectedLanguage == 'ur' ? 'لنک بھیج دیا گیا' : 'Link sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(_selectedLanguage == 'ur' ? 'بھیجیں' : 'Send'),
          ),
        ],
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
          _selectedLanguage == 'ur' ? 'لاگ ان' : 'Login',
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
                      _selectedLanguage == 'ur' ? 'خوب آپدید' : 'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedLanguage == 'ur' ? 'اپنے اکاؤنٹ میں لاگ ان کریں' : 'Login to your account',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

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
                  hintText: _selectedLanguage == 'ur' ? 'ای میل درج کریں' : 'Enter your email',
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
                  hintText: _selectedLanguage == 'ur' ? 'پاسورڈ درج کریں' : 'Enter your password',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedLanguage == 'ur' ? 'براہ کرم پاسورڈ درج کریں' : 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return _selectedLanguage == 'ur' ? 'پاسورڈ کم از کم 6 حروف کا ہونا چاہیے' : 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        activeColor: Colors.red.shade900,
                      ),
                      Text(
                        _selectedLanguage == 'ur' ? 'مجھے یاد رکھیں' : 'Remember me',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      _selectedLanguage == 'ur' ? 'پاسورڈ بھول گئے؟' : 'Forgot Password?',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoggingIn ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoggingIn
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _selectedLanguage == 'ur' ? 'لاگ ان کریں' : 'Login',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _selectedLanguage == 'ur' ? 'یا' : 'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 24),

              // Register Link
              Center(
                child: Column(
                  children: [
                    Text(
                      _selectedLanguage == 'ur' ? 'اکاؤنٹ نہیں ہے؟' : 'Don\'t have an account?',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        _selectedLanguage == 'ur' ? 'رجسٹر کریں' : 'Register',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
}
