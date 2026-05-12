import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api_config.dart';
import 'services/language_service.dart';
import 'pages/donor_dashboard_page.dart' as pages;
import 'pages/patient_dashboard_page.dart' as pages;

class RoleSwitcherPage extends StatefulWidget {
  const RoleSwitcherPage({super.key});

  @override
  State<RoleSwitcherPage> createState() => _RoleSwitcherPageState();
}

class _RoleSwitcherPageState extends State<RoleSwitcherPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  String _activeRole = 'donor'; // Default active role
  List<String> _userRoles = [];
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
    _loadUserRoles();
  }

  Future<void> _loadUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('user_roles') ?? [];

    setState(() {
      _userRoles = roles;
      // Set active role to first available role
      if (roles.contains('donor')) {
        _activeRole = 'donor';
      } else if (roles.contains('patient')) {
        _activeRole = 'patient';
      }
    });
  }

  Future<void> _switchRole(String newRole) async {
    if (_activeRole == newRole || _isSwitching) return;

    setState(() => _isSwitching = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/switch-role/unified/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'active_role': newRole,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _activeRole = newRole;
          _isSwitching = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedLanguage == 'ur'
                    ? (newRole == 'donor' ? 'ڈونر موڈ فعال' : 'پیشنٹ موڈ فعال')
                    : (newRole == 'donor' ? 'Donor mode activated' : 'Patient mode activated'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to switch role');
      }
    } catch (e) {
      setState(() => _isSwitching = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedLanguage == 'ur' ? 'کردار تبدیل کرنے میں ناکام' : 'Failed to switch role',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _activeRole == 'donor' ? Colors.blue.shade900 : Colors.red.shade900,
        elevation: 0,
        title: Text(
          _activeRole == 'donor'
              ? (_selectedLanguage == 'ur' ? 'ڈونر موڈ' : 'Donor Mode')
              : (_selectedLanguage == 'ur' ? 'پیشنٹ موڈ' : 'Patient Mode'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Menu button
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Navigate to menu
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Role Switcher Toggle (Uber-style)
          _buildRoleSwitcher(isDark),

          // Content based on active role
          Expanded(
            child: _isSwitching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: _activeRole == 'donor' ? Colors.blue.shade900 : Colors.red.shade900,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedLanguage == 'ur' ? 'موڈ تبدیل ہو رہا ہے...' : 'Switching mode...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : _activeRole == 'donor'
                    ? const pages.DonorDashboardPage()
                    : const pages.PatientDashboardPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Text(
            _selectedLanguage == 'ur' ? 'اپنا موڈ منتخب کریں:' : 'Select Your Mode:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Role Toggle Buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Donor Mode Button
                if (_userRoles.contains('donor'))
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchRole('donor'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _activeRole == 'donor'
                              ? Colors.blue.shade900
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeRole == 'donor'
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.shade900.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handshake,
                              color: _activeRole == 'donor' ? Colors.white : Colors.blue.shade700,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🤝 Donor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _activeRole == 'donor'
                                    ? Colors.white
                                    : Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedLanguage == 'ur' ? 'خون دینے والے' : 'Save Lives',
                              style: TextStyle(
                                fontSize: 11,
                                color: _activeRole == 'donor'
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Patient Mode Button
                if (_userRoles.contains('patient'))
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchRole('patient'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _activeRole == 'patient'
                              ? Colors.red.shade900
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeRole == 'patient'
                              ? [
                                  BoxShadow(
                                    color: Colors.red.shade900.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.volunteer_activism,
                              color: _activeRole == 'patient' ? Colors.white : Colors.red.shade700,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🩺 Patient',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _activeRole == 'patient'
                                    ? Colors.white
                                    : Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedLanguage == 'ur' ? 'خون کی ضرورت' : 'Need Blood',
                              style: TextStyle(
                                fontSize: 11,
                                color: _activeRole == 'patient'
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Active Role Indicator
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _activeRole == 'donor'
                  ? Colors.blue.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _activeRole == 'donor' ? Colors.blue.shade200 : Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _activeRole == 'donor' ? Icons.check_circle : Icons.check_circle,
                  color: _activeRole == 'donor' ? Colors.blue.shade700 : Colors.red.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _activeRole == 'donor'
                      ? (_selectedLanguage == 'ur'
                          ? 'ڈونر موڈ فعال ہے'
                          : 'Donor mode active')
                      : (_selectedLanguage == 'ur'
                          ? 'پیشنٹ موڈ فعال ہے'
                          : 'Patient mode active'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _activeRole == 'donor' ? Colors.blue.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
