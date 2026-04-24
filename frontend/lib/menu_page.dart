import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'find_donor.dart';
import 'edit_profile_page.dart';
import 'blood_donation_form_page.dart';
import 'feedback_page.dart';
import 'services/language_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    _languageProvider.setLanguage(languageCode);
  }

  String _translate(String key) {
    return AppTranslations.getText(key, _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _selectedLanguage == 'ur';

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: Text(
          _translate('menu'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Manage Your Experience Card
            _buildExperienceCard(context),
            const SizedBox(height: 16),

            // Find Volunteers
            _buildMenuItem(
              context,
              icon: Icons.search,
              title: _translate('find_volunteers'),
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FindDonorsPage()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Language Settings
            _buildMenuItem(
              context,
              icon: Icons.language,
              title: isUrdu ? 'زبان کی ترتیبات' : 'Language Settings',
              color: Colors.green,
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            const SizedBox(height: 8),

            // About Us
            _buildMenuItem(
              context,
              icon: Icons.business,
              title: _translate('about_us'),
              color: Colors.purple,
              onTap: () {
                _showAboutUsDialog(context);
              },
            ),
            const SizedBox(height: 8),

            // Register as Donor
            _buildMenuItem(
              context,
              icon: Icons.bloodtype,
              title: _translate('register_as_donor'),
              color: Colors.red.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BloodDonationFormPage()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Edit Profile
            _buildMenuItem(
              context,
              icon: Icons.edit,
              title: _translate('edit_profile'),
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Feedback
            _buildMenuItem(
              context,
              icon: Icons.feedback,
              title: _translate('feedback'),
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                );
              },
            ),
            const SizedBox(height: 8),

            // FAQs
            _buildMenuItem(
              context,
              icon: Icons.question_answer,
              title: _translate('faqs'),
              color: Colors.purple,
              onTap: () {
                _showFAQsDialog(context);
              },
            ),
            const SizedBox(height: 32),

            // App Version
            Center(
              child: Text(
                _translate('app_version'),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              _selectedLanguage == 'ur' ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrdu = _selectedLanguage == 'ur';

    return GestureDetector(
      onTap: () {
        _showExperienceDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gift icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: Colors.pink.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'اپنے تجربے کا انتظام کریں' : 'Manage your experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUrdu ? 'ظاہری شکل کو حسب ضرورت بنائیں، ٹولز کی تلاش کریں، اور جلد مدد حاصل کریں۔' : 'Customize appearance, explore tools, and get help fast.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _selectedLanguage == 'ur' ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    final isUrdu = _selectedLanguage == 'ur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUrdu ? 'ہمارے بارے میں' : 'About Us'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo and Name
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
                      'Blood Bank Pakistan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mission
              Text(
                isUrdu ? 'ہمارا مشن' : 'Our Mission',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUrdu
                    ? 'ہم پاکستان میں خون کی فراہمی کو آسان اور پہنچ میں لانے کے لیے وقف ہیں۔ ہم کوشش کرتے ہیں کہ lifesavers کو donate کرنے والوں سے جوڑیں۔'
                    : 'We are dedicated to making blood donation accessible and convenient across Pakistan. We strive to connect lifesavers with those in need.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Key Features
              Text(
                isUrdu ? 'اہم خصوصیات' : 'Key Features',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(isUrdu ? '🔍 رضاکار تلاش کریں' : '🔍 Find Volunteers'),
              _buildFeatureItem(isUrdu ? '📅 ڈونیشن شیڈول کریں' : '📅 Schedule Donation'),
              _buildFeatureItem(isUrdu ? '🤖 AI اسسٹنٹ' : '🤖 AI Assistant'),
              const SizedBox(height: 16),

              // Thank You
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    isUrdu ? 'हماری خدمت کا شکریہ!' : 'Thank you for using our service!',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isUrdu ? 'بند کریں' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final isUrdu = _selectedLanguage == 'ur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUrdu ? 'زبان منتخب کریں' : 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇬🇧'),
            const SizedBox(height: 12),
            _buildLanguageOption('ur', 'اردو', '🇵🇰'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isUrdu ? 'منسوخ کریں' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String languageCode, String languageName, String flag) {
    final isSelected = _selectedLanguage == languageCode;

    return GestureDetector(
      onTap: () {
        _changeLanguage(languageCode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? Colors.red.shade900 : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.red.shade900 : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.red.shade900,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showExperienceDialog(BuildContext context) {
    final isUrdu = _selectedLanguage == 'ur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUrdu ? 'اپنے تجربے کا انتظام کریں' : 'Manage your experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExperienceOption(
              context,
              icon: Icons.palette,
              title: isUrdu ? 'ظاہری شکل' : 'Appearance',
              subtitle: isUrdu ? 'تھیم اور رنگوں کو حسب ضرورت بنائیں' : 'Customize theme and colors',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildExperienceOption(
              context,
              icon: Icons.build,
              title: isUrdu ? 'ٹولز' : 'Tools',
              subtitle: isUrdu ? 'ایپ کی خصوصیات کی تلاش کریں' : 'Explore app features',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildExperienceOption(
              context,
              icon: Icons.help,
              title: isUrdu ? 'مدد اور سپورٹ' : 'Help & Support',
              subtitle: isUrdu ? 'عمومی سوالات اور مدد حاصل کریں' : 'FAQs and get help',
              onTap: () {
                Navigator.pop(context);
                _showAboutUsDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isUrdu ? 'بند کریں' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _selectedLanguage == 'ur' ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQsDialog(BuildContext context) {
    final isUrdu = _selectedLanguage == 'ur';

    final faqs = [
      {
        'question': isUrdu ? 'خون عطیہ کرنے کے لیے کون eligible ہے؟' : 'Who is eligible to donate blood?',
        'answer': isUrdu
            ? 'عموماً 18-65 سال کی عمر کے صحت مند افراد جو کم از کم 50 کلوگرام وزن کے حامل ہوں، خون عطیہ کر سکتے ہیں۔'
            : 'Generally, healthy individuals aged 18-65 who weigh at least 50 kg can donate blood.',
      },
      {
        'question': isUrdu ? 'خون عطیہ کرنے میں کتنا time لگتا ہے؟' : 'How long does the donation process take?',
        'answer': isUrdu
            ? 'پورا عمل تقریباً 45 منٹ کا ہوتا ہے، جس میں رجسٹریشن، اسکریننگ، donation اور refreshment شامل ہیں۔'
            : 'The entire process takes about 45 minutes, including registration, screening, donation, and refreshment.',
      },
      {
        'question': isUrdu ? 'میں کتنی بار خون عطیہ کر سکتا ہوں؟' : 'How often can I donate blood?',
        'answer': isUrdu
            ? 'آپ مرد ہیں تو ہر 3 ماہ بعد اور عورت ہیں تو ہر 4 ماہ بعد خون عطیہ کر سکتے ہیں۔'
            : 'Men can donate every 3 months, while women can donate every 4 months.',
      },
      {
        'question': isUrdu ? 'کیا خون عطیہ کرنا painful ہے؟' : 'Is blood donation painful?',
        'answer': isUrdu
            ? 'نہیں، آپ کو صرف ایک چھوٹی سوائی کا احساس ہوگا جو کچھ سیکنڈز کے لیے ہوتی ہے۔'
            : 'No, you will only feel a small pinch that lasts for a few seconds.',
      },
      {
        'question': isUrdu ? 'خون عطیہ کرنے کے بعد کیا کرنا چاہیے؟' : 'What should I do after donating blood?',
        'answer': isUrdu
            ? 'donation کے بعد پانی کثرت سے پئیں، بھاری something نہ اٹھائیں، اور اگر کوئی علامت محسوس ہو تو ڈاکٹر سے رجوع کریں۔'
            : 'After donation, drink plenty of fluids, avoid heavy lifting, and consult a doctor if you experience any symptoms.',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.question_answer, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(child: Text(isUrdu ? 'عمومی سوالات' : 'Frequently Asked Questions')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return ExpansionTile(
                title: Text(
                  faq['question'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faq['answer'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isUrdu ? 'بند کریں' : 'Close'),
          ),
        ],
      ),
    );
  }
}