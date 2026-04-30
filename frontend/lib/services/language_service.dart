import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  bool get isUrdu => _currentLanguage == 'ur';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
    notifyListeners();
  }

  // Get text direction based on language
  TextDirection get textDirection {
    return _currentLanguage == 'ur' ? TextDirection.rtl : TextDirection.ltr;
  }
}

// Translation strings
class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Menu
      'menu': 'Menu',
      'find_volunteers': 'Find Volunteers',
      'schedule_donation': 'Schedule Donation',
      'emergency': 'Emergency',
      'about_us': 'About Us',
      'register_as_donor': 'Register as Donor',
      'edit_profile': 'Edit Profile',
      'feedback': 'Feedback',
      'about_blood_donation': 'About Blood Donation',

      // Welcome
      'welcome_to_blood_bank': 'Welcome to Blood Bank',
      'save_lives_subtitle': 'Save lives by donating blood',
      'active_donors': 'Active Donors',
      'lives_saved': 'Lives Saved',

      // Emergency
      'emergency_helpline': 'Emergency Helpline',
      'emergency_call': 'Call',
      'pakistan_emergency': 'Call: 1122 (Pakistan)',

      // Find Volunteers Page
      'search_by_location': 'Search by location or name',
      'view_on_map': 'View on Map',
      'no_donors_found': 'No volunteers found',
      'try_adjusting_filters': 'Try adjusting your search or filters',
      'clear_filters': 'Clear Filters',

      // Map Page
      'donor_locations': 'Volunteer Locations',
      'my_location': 'My Location',
      'filter': 'Filter',
      'volunteers_found': 'volunteers found',

      // Filter
      'filter_by_blood_group': 'Filter by Blood Group',
      'clear_filter': 'Clear Filter',

      // Blood Groups
      'blood_group_a_positive': 'A+',
      'blood_group_a_negative': 'A-',
      'blood_group_b_positive': 'B+',
      'blood_group_b_negative': 'B-',
      'blood_group_ab_positive': 'AB+',
      'blood_group_ab_negative': 'AB-',
      'blood_group_o_positive': 'O+',
      'blood_group_o_negative': 'O-',

      // General
      'available': 'Available',
      'unavailable': 'Unavailable',
      'general_call': 'Call',
      'message': 'Message',
      'location': 'Location',
      'contact': 'Contact',
      'last_donation': 'Last Donation',
      'total_donations': 'Total Donations',

      // Donation Info
      'who_can_donate': 'Who Can Donate?',
      'benefits_of_donation': 'Benefits of Donation:',
      'process_duration': 'Process Duration:',
      'age_requirement': 'Age: 18-65 years old',
      'weight_requirement': 'Weight: At least 50 kg',
      'health_requirement': 'Good health condition',
      'no_tattoos': 'No recent tattoos or piercings',
      'not_pregnant': 'Not pregnant or breastfeeding',
      'save_lives': 'Save up to 3 lives per donation',
      'free_screening': 'Free health screening',
      'reduced_heart_disease': 'Reduced risk of heart disease',
      'burn_calories': 'Burn calories',
      'registration_time': 'Registration: 10-15 minutes',
      'screening_time': 'Screening: 15-20 minutes',
      'donation_time': 'Donation: 10-15 minutes',
      'refreshment_time': 'Refreshment: 10 minutes',
      'total_time': 'Total: ~45 minutes',

      // Provinces
      'punjab': 'Punjab',
      'sindh': 'Sindh',
      'khyber_pakhtunkhwa': 'Khyber Pakhtunkhwa',
      'balochistan': 'Balochistan',

      // App Info
      'app_version': 'Blood Bank App v1.0.0',
      'close': 'Close',
      'submit': 'Submit',
      'feedback_title': 'Send us your feedback',
      'feedback_hint': 'Tell us what you think about the app...',
      'feedback_submitted': 'Thank you for your feedback!',
      'feedback_error': 'Please enter your feedback',
      'your_feedback': 'Your Feedback',
      'rate_us': 'Rate Us',
      'report_issue': 'Report Issue',
      'contact_developer': 'Contact Developer',
      'subject': 'Subject',
      'feedback_message': 'Message',
      'send_feedback': 'Send Feedback',
      'faqs': 'FAQs',
    },
    'ur': {
      // Menu
      'menu': 'مینیو',
      'find_volunteers': 'رضاکار تلاش کریں',
      'schedule_donation': '_donation کا شیڈول',
      'emergency': 'ہنگامی صورت حال',
      'about_us': 'ہمارے بارے میں',
      'register_as_donor': ' donnر کے طور پر رجسٹر کریں',
      'edit_profile': 'پروفائل ترمیم کریں',
      'feedback': 'رائے',
      'about_blood_donation': '_donation کے بارے میں',

      // Welcome
      'welcome_to_blood_bank': 'blid بینک میں خوش آمدید',
      'save_lives_subtitle': 'blood donate کر کے زندگیاں بچائیں',
      'active_donors': 'فعال  donatehr',
      'lives_saved': 'بچی ہوئی زندگیاں',

      // Emergency
      'emergency_helpline': 'ہنگامی ہیلپ لائن',
      'emergency_call': 'کال کریں',
      'pakistan_emergency': 'کال: 1122 (پاکستان)',

      // Find Volunteers Page
      'search_by_location': 'مقام یا نام سے تلاش کریں',
      'view_on_map': 'map پر دیکھیں',
      'no_donors_found': 'کوئی razaکار نہیں ملا',
      'try_adjusting_filters': 'اپنی تلاش یا فلٹرز کو ایڈجسٹ کریں',
      'clear_filters': 'فلٹر صاف کریں',

      // Map Page
      'donor_locations': 'razاکار کے مقامات',
      'my_location': 'میرا مقام',
      'filter': 'فلٹر',
      'volunteers_found': 'razdacar ملا',

      // Filter
      'filter_by_blood_group': 'blod گروپ کے مطابق فلٹر کریں',
      'clear_filter': 'فلٹر صاف کریں',

      // Blood Groups
      'blood_group_a_positive': 'اے +',
      'blood_group_a_negative': 'اے -',
      'blood_group_b_positive': 'بی +',
      'blood_group_b_negative': 'بی -',
      'blood_group_ab_positive': 'اے بی +',
      'blood_group_ab_negative': 'اے بی -',
      'blood_group_o_positive': 'او +',
      'blood_group_o_negative': 'او -',

      // General
      'available': 'دستیاب',
      'unavailable': 'غیر دستیاب',
      'general_call': 'کال کریں',
      'message': 'پیغام',
      'location': 'مقام',
      'contact': 'رابطہ',
      'last_donation': 'آخری donetn',
      'total_donations': 'کل doations',

      // Donation Info
      'who_can_donate': 'کوں donate کر سکتا ہے؟',
      'benefits_of_donation': 'donetn کے فوائد:',
      'process_duration': 'عمل کی مدت:',
      'age_requirement': 'عمریت: 18-65 سال',
      'weight_requirement': 'وزن: کم از کم 50 کلوگرام',
      'health_requirement': 'اچھی صحت کی حالت',
      'no_tattoos': 'حالیہ ٹیٹو یا پیرسنگ نہیں',
      'not_pregnant': 'حاملہ یا دودھ پلانے والی نہیں',
      'save_lives': 'فی doatin 3 زندگیاں بچائیں',
      'free_screening': 'مفت ہیلتھ اسکریننگ',
      'reduced_heart_disease': 'hest کی بیماریوں کا خطرہ کم',
      'burn_calories': 'کیلوریز جلائیں',
      'registration_time': 'رجسٹریشن: 10-15 منٹ',
      'screening_time': 'اسکریننگ: 15-20 منٹ',
      'donation_time': 'doation: 10-15 منٹ',
      'refreshment_time': 'تازگی: 10 منٹ',
      'total_time': 'کل: ~45 منٹ',

      // Provinces
      'punjab': 'پنجاب',
      'sindh': 'سندھ',
      'khyber_pakhtunkhwa': 'خیبر پختونخوا',
      'balochistan': 'بلوچستان',

      // App Info
      'app_version': 'blod بینک ایپ v1.0.0',
      'close': 'بند کریں',
      'submit': 'جمع کروائیں',
      'feedback_title': 'ہمیں اپنی رائے بھیجیں',
      'feedback_hint': 'ہمیں بتائیں کہ آپ ایپ کے بارے میں کیا سوچتے ہیں...',
      'feedback_submitted': 'آپ کی رائے کا شکریہ!',
      'feedback_error': 'براہ کرم اپنی رائے درج کریں',
      'your_feedback': 'آپ کی رائے',
      'rate_us': 'ہمیں درجہ دیں',
      'report_issue': 'مسلہ کی اطلاع دیں',
      'contact_developer': 'ڈویلپر سے رابطہ کریں',
      'subject': 'موضوع',
      'feedback_message': 'پیغام',
      'send_feedback': 'رائے بھیجیں',
      'faqs': 'عمومی سوالات',
    },
  };

  static String getText(String key, String language) {
    return _translations[language]?[key] ?? _translations['en']?[key] ?? key;
  }
}

// Extension for easy access to translations
extension Translations on BuildContext {
  String translate(String key) {
    final languageProvider = LanguageProvider();
    return AppTranslations.getText(key, languageProvider.currentLanguage);
  }
}