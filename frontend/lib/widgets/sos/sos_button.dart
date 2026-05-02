import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';
import '../../services/emergency_contacts_service.dart';
import '../../services/sos_notification_service.dart';
import '../../services/rate_limiter_service.dart';

class SOSButton extends StatefulWidget {
  final Function(bool)? onSOSStateChanged;
  final Function(bool, dynamic)? onSOSActivatedWithLocation; // New callback for map
  final bool showLabels;
  final bool testMode; // Added test mode for easier testing

  const SOSButton({
    super.key,
    this.onSOSStateChanged,
    this.onSOSActivatedWithLocation,
    this.showLabels = true,
    this.testMode = false, // Default to false
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with TickerProviderStateMixin {
  bool _isActive = false;
  bool _isLongPressing = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  Timer? _gracePeriodTimer;
  int _gracePeriodCountdown = 10;
  final LocationService _locationService = LocationService();
  final EmergencyContactsService _contactsService = EmergencyContactsService();
  final SOSNotificationService _notificationService = SOSNotificationService();
  final SOSRateLimiter _rateLimiter = SOSRateLimiter();

  late AnimationController _pulseController;
  late AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _countdownTimer?.cancel();
    _gracePeriodTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleLongPressStart(LongPressStartDetails details) async {
    if (_isActive) return;

    try {
      // Skip rate limiter check in test mode
      if (!widget.testMode) {
        await _rateLimiter.canActivateSOS();
      }

      setState(() {
        _isLongPressing = true;
        _countdown = 3;
      });

      _countdown = 3;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
          // Safe vibration with error handling
          try {
            Vibration.vibrate(duration: 50);
          } catch (e) {
            // Vibration not supported, ignore error
          }
        } else {
          timer.cancel();
          _activateSOS();
        }
      });

      _countdownController.forward().then((_) {
        _countdownController.reverse();
      });

    } catch (e) {
      if (e is SOSRateLimitException) {
        _showRateLimitDialog(e);
      } else {
        _showErrorDialog('Error activating SOS: $e');
      }
      setState(() {
        _isLongPressing = false;
      });
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isActive) return;

    _countdownTimer?.cancel();
    setState(() {
      _isLongPressing = false;
      _countdown = 3;
    });
  }

  Future<void> _activateSOS() async {
    setState(() {
      _isLongPressing = false;
      _isActive = true;
    });

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    if (!_contactsService.hasMinimumContacts()) {
      _showNoContactsDialog();
      setState(() => _isActive = false);
      return;
    }

    await _locationService.getCurrentLocation();

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) {
      setState(() => _isActive = false);
      return;
    }

    try {
      await _rateLimiter.recordSOSActivation();
      await _notificationService.startSiren();
      await _notificationService.showSOSActivatedNotification();
      await _sendEmergencyAlerts();
      _startGracePeriod();
      widget.onSOSStateChanged?.call(true);

      // Notify parent with location for automatic map display
      final currentPosition = _locationService.currentPosition;
      widget.onSOSActivatedWithLocation?.call(true, currentPosition);

    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error activating SOS: $e');
        setState(() => _isActive = false);
      }
    }
  }

  void _startGracePeriod() {
    _gracePeriodCountdown = 10;
    _gracePeriodTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_gracePeriodCountdown > 0) {
        setState(() {
          _gracePeriodCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _cancelSOS() async {
    _gracePeriodTimer?.cancel();
    await _notificationService.stopSiren();
    await _notificationService.showSOSCancelledNotification();
    await _notificationService.cancelAllNotifications();
    await _rateLimiter.recordSOSCancellation();

    setState(() {
      _isActive = false;
      _gracePeriodCountdown = 10;
    });

    widget.onSOSStateChanged?.call(false);
  }

  Future<void> _sendEmergencyAlerts() async {
    // Get location and contacts for SMS sending
    final location = _locationService.getLocationMessage();
    final contacts = _contactsService.contacts;

    if (contacts.isNotEmpty) {
      // Prepare emergency message
      final emergencyMessage = '''
🚨 EMERGENCY SOS ALERT 🚨

I need help! This is an emergency.

$location

Please contact me immediately!''';

      // Send SMS to each emergency contact
      for (var contact in contacts) {
        try {
          final smsUri = Uri(
            scheme: 'sms',
            path: contact.phone,
            queryParameters: {
              'body': emergencyMessage.trim(),
            },
          );

          // Check if SMS launching is supported
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
          }
        } catch (e) {
          // Error sending SMS to contact, continue with next contact
        }

        // Add small delay between SMS sends to avoid overwhelming the system
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Confirm Emergency'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you in danger? This will alert your emergency contacts.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '⚠️ IMPORTANT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Misuse of emergency alerts is illegal and can result in legal consequences.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, I need help'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Emergency Contacts'),
        content: const Text('Please add at least one emergency contact before using SOS.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRateLimitDialog(SOSRateLimitException exception) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('SOS Temporarily Disabled'),
          ],
        ),
        content: Text(exception.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isActive) ...[
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade700.withValues(alpha:0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _cancelSOS,
                      borderRadius: BorderRadius.circular(100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_gracePeriodCountdown > 0)
                            Text(
                              'Auto-send in ${_gracePeriodCountdown}s',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ] else ...[
          GestureDetector(
            onLongPressStart: _handleLongPressStart,
            onLongPressEnd: _handleLongPressEnd,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isLongPressing
                      ? 1.1
                      : 1.0 + (_pulseController.value * 0.05),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade700,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade700.withValues(alpha:0.3),
                          blurRadius: 15,
                          spreadRadius: _isLongPressing ? 8 : 3,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          // Add tap feedback for testing
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hold the SOS button for 3 seconds to activate'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLongPressing) ...[
                              Text(
                                '$_countdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'HOLD...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (3 - _countdown) / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.sos,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'SOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.showLabels)
                                const Text(
                                  'Hold 3 seconds',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}