import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'find_donor.dart';
import 'emergency_page.dart';
import 'ai_assistant_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';
import 'theme_provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _carouselIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.surface
          : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: Row(
          children: [
            // Profile Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.red.shade700,
                  child: const Icon(Icons.person, color: Colors.white, size: 26),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.favorite, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              "Blood Donor",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : 24,
              ),
            ),
          ],
        ),
        actions: [
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  // TODO: notification functionality
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Theme Toggle
          _themeToggle(),
          // Desktop Navigation Buttons
          if (!isSmallScreen) ...[
            _navButton("Home", Icons.home, null),
            _navButton("Find donor", Icons.search, const FindDonorsPage()),
            _navButton("Blood Request", Icons.favorite, const EmergencyPage()),
            _navButton("AI Assistant", Icons.auto_awesome, const AIAssistantPage()),
            _navButton("Login", Icons.login, const LoginPage()),
            _actionButton("Register", Icons.person_add, const RegisterPage(), Colors.white, Colors.red.shade900),
          ],
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _savingLivesBadge(),
            _findNearbyDonorCard(isDark, isSmallScreen),
            _quickActionsCard(isSmallScreen),
            _imageCarousel(isDark),
            _whyChooseUsSection(isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home, "Home", 0, null),
                _buildBottomNavItem(Icons.water_drop, "Blood Request", 1, const EmergencyPage()),
                _buildBottomNavItem(Icons.chat, "AI Assistant", 2, const AIAssistantPage()),
                _buildBottomNavItem(Icons.menu, "Menu", 3, const MenuPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _savingLivesBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "❤️ SAVING LIVES TOGETHER",
        style: TextStyle(
          color: Colors.red.shade900,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _findNearbyDonorCard(bool isDark, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Find Nearby Donor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Search ...",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FindDonorsPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard(bool isSmall) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _actionCard(false, _buildBloodDropWithPlus(), const EmergencyPage()),
                const SizedBox(height: 8),
                const Text(
                  "Add Request",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _actionCard(false, Icons.location_on, const FindDonorsPage()),
                const SizedBox(height: 8),
                const Text(
                  "Nearby Hospital",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _actionCard(false, Icons.check_circle, const FindDonorsPage()),
                const SizedBox(height: 8),
                const Text(
                  "Nearby Donor",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodDropWithPlus() {
    return Stack(
      alignment: Alignment.center,
      children: const [
        Icon(Icons.water_drop, color: Colors.red, size: 48),
        Icon(Icons.add, color: Colors.white, size: 32),
      ],
    );
  }

  Widget _actionCard(bool isDark, dynamic icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade900, width: 2),
        ),
        child: icon is Widget ? icon : Icon(icon, size: 48, color: Colors.red.shade900),
      ),
    );
  }

  Widget _imageCarousel(bool isDark) {
    final List<Map<String, String>> carouselItems = List.generate(5, (index) {
      final titles = ['Donate Blood', 'Save Lives', 'Be a Hero', 'Join Us', 'Help Others'];
      return {
        'image': 'assets/blood_donation$index.jpg',
        'title': titles[index],
      };
    });

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _carouselIndex = index;
                });
              },
              itemCount: carouselItems.length,
              itemBuilder: (context, index) {
                final item = carouselItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade900, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Placeholder for image
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Image ${index + 1}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        // Uncomment to use real images:
                        // Image.asset(
                        //   item['image']!,
                        //   fit: BoxFit.cover,
                        //   errorBuilder: (context, error, stackTrace) {
                        //     return Center(
                        //       child: Column(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           const Icon(Icons.error, size: 64),
                        //           Text('Image not found'),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _carouselIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _carouselIndex == index
                      ? Colors.red.shade900
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _whyChooseUsSection(bool isDark) {
    final List<Map<String, dynamic>> features = [
      {'title': 'Emergency Blood Requests', 'icon': Icons.emergency, 'color': Colors.red, 'description': 'Urgent blood requests in real-time'},
      {'title': 'Find Donors Nearby', 'icon': Icons.location_on, 'color': Colors.blue, 'description': 'Locate donors in your area'},
      {'title': '24/7 AI Assistant', 'icon': Icons.smart_toy, 'color': Colors.purple, 'description': 'Get help anytime'},
      {'title': 'Verified Donors', 'icon': Icons.verified, 'color': Colors.green, 'description': 'All donors are verified'},
      {'title': 'Real-time Notifications', 'icon': Icons.notifications_active, 'color': Colors.orange, 'description': 'Instant alerts for requests'},
      {'title': 'Simple & Fast Process', 'icon': Icons.flash_on, 'color': Colors.teal, 'description': 'Quick and easy donations'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Choose Us?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Features that save lives",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              final color = feature['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade300 : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(String title, IconData icon, Widget? page) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        iconColor: Colors.white,
      ),
      onPressed: page == null
          ? () {}
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, Widget page, Color bg, Color text) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _themeToggle() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return IconButton(
          icon: Icon(
            mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white,
          ),
          onPressed: toggleTheme,
        );
      },
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index, Widget? page) {
    return Expanded(
      child: InkWell(
        onTap: page == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
      ),
    );
  }
}
