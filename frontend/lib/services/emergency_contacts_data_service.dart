import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactData {
  final String name;
  final String phone;

  EmergencyContactData({
    required this.name,
    required this.phone,
  });

  factory EmergencyContactData.fromString(String data) {
    final parts = data.split('|');
    return EmergencyContactData(
      name: parts.length > 1 ? parts[1] : 'Unknown',
      phone: parts.length > 2 ? parts[2] : '',
    );
  }
}

class EmergencyContactsDataService {
  static const String _contactsKey = 'emergency_contacts';

  static Future<List<EmergencyContactData>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_contactsKey) ?? [];

      return contactsJson.map((json) {
        return EmergencyContactData.fromString(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> hasEmergencyContacts() async {
    final contacts = await getEmergencyContacts();
    return contacts.isNotEmpty;
  }

  static Future<int> getContactsCount() async {
    final contacts = await getEmergencyContacts();
    return contacts.length;
  }
}
