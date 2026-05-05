import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String? email;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class EmergencyContactsService {
  static final EmergencyContactsService _instance = EmergencyContactsService._internal();
  factory EmergencyContactsService() => _instance;
  EmergencyContactsService._internal();

  final List<EmergencyContact> _contacts = [];
  static const String _storageKey = 'emergency_contacts';

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  Future<void> loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_storageKey);

      if (contactsJson != null) {
        _contacts.clear();
        for (var contactJson in contactsJson) {
          final parts = contactJson.split('|');
          if (parts.length >= 3) {
            _contacts.add(EmergencyContact(
              id: parts[0],
              name: parts[1],
              phone: parts[2],
              email: parts.length > 3 ? parts[3] : null,
            ));
          }
        }
      }
    } catch (e) {
      // Error loading contacts: $e
    }
  }

  Future<void> saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = _contacts.map((contact) =>
        '${contact.id}|${contact.name}|${contact.phone}|${contact.email ?? ''}'
      ).toList();

      await prefs.setStringList(_storageKey, contactsJson);
    } catch (e) {
      // Error saving contacts: $e
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    _contacts.add(contact);
    await saveContacts();
  }

  Future<void> removeContact(String id) async {
    _contacts.removeWhere((contact) => contact.id == id);
    await saveContacts();
  }

  Future<void> updateContact(EmergencyContact updatedContact) async {
    final index = _contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      await saveContacts();
    }
  }

  bool hasMinimumContacts() {
    return _contacts.isNotEmpty;
  }

  String getAllContactsInfo() {
    if (_contacts.isEmpty) {
      return 'No emergency contacts configured';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < _contacts.length; i++) {
      final contact = _contacts[i];
      buffer.writeln('Contact ${i + 1}: ${contact.name}');
      buffer.writeln('Phone: ${contact.phone}');
      if (contact.email != null && contact.email!.isNotEmpty) {
        buffer.writeln('Email: ${contact.email}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}