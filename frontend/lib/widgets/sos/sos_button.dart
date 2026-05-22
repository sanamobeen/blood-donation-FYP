import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/location_service.dart';
import '../../services/emergency_contacts_data_service.dart';

class SOSButton extends StatefulWidget {
  final Function(Position)? onLocationObtained;
  final bool testMode;

  const SOSButton({
    super.key,
    this.onLocationObtained,
    this.testMode = false,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isPressed = false;
  int _countdown = 3;
  bool _isTriggered = false;
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSiren = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) async {
        if (_isTriggered || _isLoading) return;

        setState(() {
          _isPressed = true;
          _countdown = 3;
        });

        // Vibrate for feedback
        try {
          Vibration.vibrate(duration: 200);
        } catch (e) {
          // Vibration may not be supported on all devices
        }

        // Start countdown
        for (int i = 3; i > 0; i--) {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          setState(() {
            _countdown = i - 1;
          });
          if (i > 1) {
            try {
              Vibration.vibrate(duration: 100);
            } catch (e) {
              // Ignore vibration errors
            }
          }
        }

        if (!mounted) return;

        // Check if emergency contacts exist
        final hasContacts = await EmergencyContactsDataService.hasEmergencyContacts();
        if (!hasContacts) {
          if (!mounted) return;
          _showNoContactsDialog();
          setState(() {
            _isPressed = false;
            _countdown = 3;
          });
          return;
        }

        // Show confirmation dialog
        final emergencyData = await _showConfirmationDialog();
        if (!mounted) return;

        if (emergencyData != null) {
          await _triggerSOS(emergencyData);
        } else {
          setState(() {
            _isPressed = false;
            _countdown = 3;
          });
        }
      },
      onLongPressEnd: (_) {
        if (_countdown > 0 && mounted) {
          setState(() {
            _isPressed = false;
            _countdown = 3;
          });
        }
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _isTriggered
                ? [Colors.green.shade700, Colors.green.shade900]
                : _isPressed
                    ? [Colors.orange.shade700, Colors.red.shade900]
                    : [Colors.red.shade600, Colors.red.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isTriggered ? Colors.green : Colors.red).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              )
            : _isTriggered
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPressed ? Icons.timer : Icons.sos,
                        color: Colors.white,
                        size: 50,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPressed ? "$_countdown" : "SOS",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      if (!_isPressed)
                        Text(
                          "Long Press",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Future<Map<String, String>?> _showConfirmationDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final bloodRequestController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.red.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Emergency Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Please provide your emergency information:",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contact Number field
                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Blood Request field
                    TextField(
                      controller: bloodRequestController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Blood Request Details *',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        hintText: 'Additional details (e.g., "2 units needed, urgent")',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Legal warning (compact)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange.shade700, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "WARNING",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "False emergency alerts are a criminal offense",
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isPressed = false;
                      _countdown = 3;
                    });
                    nameController.dispose();
                    contactController.dispose();
                    bloodRequestController.dispose();
                    Navigator.of(dialogContext).pop(null);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Validate fields
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter your name'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (contactController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter your contact number'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (bloodRequestController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please describe your blood request'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    // Create emergency data map
                    final emergencyData = {
                      'name': nameController.text.trim(),
                      'contact': contactController.text.trim(),
                      'bloodRequest': bloodRequestController.text.trim(),
                    };

                    // Clean up controllers
                    nameController.dispose();
                    contactController.dispose();
                    bloodRequestController.dispose();

                    // Close dialog and return emergency data
                    Navigator.of(dialogContext).pop(emergencyData);
                  },
                  child: const Text("SEND SOS"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _triggerSOS(Map<String, String> emergencyData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Get GPS location
      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;

      // Step 2: Get address from coordinates
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Step 3: Get emergency contacts
      final contacts = await EmergencyContactsDataService.getEmergencyContacts();

      if (contacts.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isPressed = false;
        });
        _showNoContactsDialog();
        return;
      }

      if (!mounted) return;

      // Step 4: Show preview dialog
      final shouldProceed = await _showContactsPreviewDialog(contacts, address);
      if (!mounted) return;

      if (!shouldProceed) {
        setState(() {
          _isLoading = false;
          _isPressed = false;
        });
        return;
      }

      // Step 5: Create Google Maps link and SOS message
      final mapLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      final message = '''
🚨 EMERGENCY SOS ALERT 🚨

This is an automated emergency alert from the Blood Donation App.

👤 PERSON IN NEED: ${emergencyData['name']}
📞 CONTACT: ${emergencyData['contact']}
🩸 BLOOD REQUEST: ${emergencyData['bloodRequest']}

📍 LOCATION: $address
📍 GPS Coordinates: ${position.latitude}, ${position.longitude}

🗺️ View Location: $mapLink

⏰ Time: ${DateTime.now().toString()}

THIS IS A REAL EMERGENCY. PLEASE CONTACT THE USER IMMEDIATELY.
''';

      // Step 6: Send SMS to all emergency contacts
      int successCount = 0;
      for (final contact in contacts) {
        try {
          final smsUri = Uri.parse('sms:${contact.phone}?body=${Uri.encodeComponent(message)}');
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
            successCount++;
            // Small delay between SMS sends
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e) {
          // Continue with other contacts even if one fails
          // Silently continue to next contact
        }
      }

      if (!mounted) return;

      setState(() {
        _isTriggered = true;
        _isLoading = false;
        _isPressed = false;
      });

      // Show success dialog
      if (!mounted) return;
      _showSuccessDialog(address, contacts.length, successCount);

      // Play siren sound
      _playSiren();

      // Call back with location
      widget.onLocationObtained?.call(position);

      // Reset after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _isTriggered = false;
          });
        }
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isPressed = false;
      });

      // Show detailed error dialog
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showSuccessDialog(String address, int contactsCount, int successCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "SOS Alert Sent!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Emergency SOS has been triggered. SMS sent to $successCount of $contactsCount contact(s).",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Your Location",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Stay calm. Help is on the way.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "SOS Error",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Failed to trigger SOS. Please check the following:",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 12, color: Colors.red.shade900),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Make sure location services are enabled and you have granted location permissions.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No Emergency Contacts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You haven't added any emergency contacts yet.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                "Please add emergency contacts first to use the SOS feature.",
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showContactsPreviewDialog(
    List<EmergencyContactData> contacts,
    String address,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.contacts, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Confirm Emergency Contacts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SOS alert will be sent to ${contacts.length} contact(s):",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: contacts.map((contact) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Your location: $address",
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send SOS Alert'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _stopSiren();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSiren() async {
    if (_isPlayingSiren) return;

    try {
      setState(() {
        _isPlayingSiren = true;
      });

      // Use vibration and system sounds as siren (whoop-whoop-whoop pattern)
      for (int i = 0; i < 10; i++) {
        if (!_isPlayingSiren || !mounted) break;

        // Long vibration (whoop)
        try {
          await Vibration.vibrate(duration: 300);
        } catch (e) {
          // Ignore vibration errors
        }

        await Future.delayed(const Duration(milliseconds: 300));

        // Short pause (woo)
        await Future.delayed(const Duration(milliseconds: 200));

        // Long vibration again (whoop)
        try {
          await Vibration.vibrate(duration: 300);
        } catch (e) {
          // Ignore vibration errors
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        setState(() {
          _isPlayingSiren = false;
        });
      }
    } catch (e) {
      setState(() {
        _isPlayingSiren = false;
      });
    }
  }

  Future<void> _stopSiren() async {
    if (mounted) {
      setState(() {
        _isPlayingSiren = false;
      });
    }
    await _audioPlayer.stop();
  }
}
