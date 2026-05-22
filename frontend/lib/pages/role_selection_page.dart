import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import '../simple_registration_page.dart';
import '../services/blood_request_service.dart';
import '../find_donor.dart';
import 'patient_landing_page.dart';
import 'donor_dashboard_page.dart';
import '../../blood_donor_home.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() {
      _isLoading = true;
    });

    // Check if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      // User is logged in - show auth dialog for role switching
      setState(() {
        _isLoading = false;
      });
      _showRoleSwitchDialog(role);
      return;
    }

    // New user - navigate to simple registration with role context
    setState(() {
      _isLoading = false;
    });

    // Navigate to simple registration page with role parameter
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SimpleRegistrationPage(role: role)),
    );
  }

  void _showRoleSwitchDialog(String role) {
    final roleText = role == 'patient' ? 'Patient' : 'Donor';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch to $roleText'),
        content: Text('You are already logged in. Use the menu to switch roles instead.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLoginAndNavigate(String role) async {
    // For patients, always show the patient landing page
    if (role == 'patient') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PatientLandingPage()),
      );
      return;
    }

    // For donors, check login and proceed normally
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      // Show login/register dialog
      _showAuthDialog(role);
    } else {
      // User is logged in, proceed to dashboard
      await _selectRole(role);
    }
  }

  void _showAuthDialog(String role) {
    final roleText = role == 'patient' ? 'find blood' : 'donate';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('To $roleText, please login or create an account first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to simple registration page with role context
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SimpleRegistrationPage(role: role)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Wallpaper.jfif',
              fit: BoxFit.cover,
            ),
          ),

          // Red overlay
          Positioned.fill(
            child: Container(
              color: Colors.red.shade700.withValues(alpha: 0.3),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                const SizedBox(height: 40),

                // Logo and Title
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Gemini_Generated_Image_kpueiokpueiokpue.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Blood Donation',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Connect with lifesavers across Pakistan.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Your blood donation can save up to 3 lives.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Role Selection Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // I NEED BLOOD Card
                      _buildRoleCard(
                        isDark: isDark,
                        icon: Icons.favorite,
                        title: 'I Need Blood',
                        description: 'Find blood donors near you',
                        color: Colors.red,
                        isLoading: _isLoading,
                        onTap: () => _checkLoginAndNavigate('patient'),
                      ),

                      const SizedBox(height: 16),

                      // I WANT TO DONATE Card
                      _buildRoleCard(
                        isDark: isDark,
                        icon: Icons.volunteer_activism,
                        title: 'I Want to Donate',
                        description: 'Save lives by donating blood',
                        color: Colors.red,
                        isLoading: _isLoading,
                        onTap: () => _checkLoginAndNavigate('donor'),
                      ),

                      const SizedBox(height: 16),

                      // EMERGENCY SOS Card
                      _buildEmergencySOSCard(
                        isDark: isDark,
                        onTap: () => _showEmergencySOSDialog(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Existing user prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final Color displayColor = color == Colors.red ? Colors.red.shade900 : Colors.blue.shade900;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: displayColor,
              ),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: displayColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySOSCard({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.shade900,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.sos,
                color: Colors.red.shade900,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Urgent Blood Request',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Need blood immediately',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.red.shade900,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencySOSDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    String? selectedBloodGroup;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.sos, color: Colors.red.shade900, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    '⚠️ Emergency Mode: This will immediately alert nearby donors',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Patient Name *',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.person, size: 20, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.bloodtype, size: 20, color: Colors.black54),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedBloodGroup,
                            hint: const Text('Select Blood Group', style: TextStyle(fontSize: 14, color: Colors.black)),
                            isExpanded: true,
                            iconSize: 20,
                            underline: const SizedBox(),
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            items: const [
                              DropdownMenuItem(value: 'A+', child: Text('A+', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'A-', child: Text('A-', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'B+', child: Text('B+', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'B-', child: Text('B-', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'AB+', child: Text('AB+', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'AB-', child: Text('AB-', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'O+', child: Text('O+', style: TextStyle(fontSize: 14, color: Colors.black))),
                              DropdownMenuItem(value: 'O-', child: Text('O-', style: TextStyle(fontSize: 14, color: Colors.black))),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedBloodGroup = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Emergency Contact *',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.phone, size: 20, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade900, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate fields
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter patient name')),
                  );
                  return;
                }
                if (selectedBloodGroup == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select blood group')),
                  );
                  return;
                }
                if (contactController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter emergency contact')),
                  );
                  return;
                }

                // Show loading
                setDialogState(() {
                  _isLoading = true;
                });

                // Capture context before async gap
                final scaffoldMessengerContext = context;
                final navigationContext = context;

                // Close dialog immediately before async operation
                if (mounted) {
                  Navigator.of(context).pop();
                }

                try {
                  // Create emergency blood request
                  await BloodRequestService.createBloodRequest(
                    patientName: nameController.text.trim(),
                    emergencyContact: contactController.text.trim(),
                    bloodGroup: selectedBloodGroup!,
                    gender: 'Other', // Default for emergency
                    province: 'Punjab', // Default - will use GPS location in future
                    district: 'Lahore', // Default - will use GPS location in future
                    localLevel: '',
                    unitsRequired: 1, // Default for emergency
                    requiredDate: DateTime.now().toString().split(' ')[0],
                    requiredTime: '${DateTime.now().hour}:${DateTime.now().minute}',
                    caseDescription: 'EMERGENCY - URGENT BLOOD REQUIRED',
                  );

                  setDialogState(() {
                    _isLoading = false;
                  });

                  // Show success message and navigate
                  if (scaffoldMessengerContext.mounted) {
                    ScaffoldMessenger.of(scaffoldMessengerContext).showSnackBar(
                      const SnackBar(
                        content: Text('🚨 Emergency request sent! Finding donors...'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }

                  // Navigate to find donors page with blood group filter
                  if (navigationContext.mounted) {
                    Navigator.pushReplacement(
                      navigationContext,
                      MaterialPageRoute(
                        builder: (context) => const FindDonorsPage(),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() {
                    _isLoading = false;
                  });

                  if (scaffoldMessengerContext.mounted) {
                    ScaffoldMessenger.of(scaffoldMessengerContext).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
              ),
              child: const Text('SEND EMERGENCY REQUEST'),
            ),
          ],
        ),
      ),
    );
  }
}
