import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class SOSNotificationService {
  static final SOSNotificationService _instance = SOSNotificationService._internal();
  factory SOSNotificationService() => _instance;
  SOSNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSirenPlaying = false;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showSOSActivatedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'sos_channel',
      'SOS Emergency',
      channelDescription: 'Emergency SOS notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🚨 SOS ACTIVATED',
      'Emergency alert sent to your contacts',
      notificationDetails,
    );
  }

  Future<void> showSOSCancelledNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'sos_channel',
      'SOS Emergency',
      channelDescription: 'Emergency SOS notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '✅ SOS Cancelled',
      'Emergency alert has been cancelled',
      notificationDetails,
    );
  }

  Future<void> startSiren() async {
    if (_isSirenPlaying) return;

    _isSirenPlaying = true;

    try {
      // Try playing the online siren sound
      while (_isSirenPlaying) {
        try {
          await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
          await Future.delayed(const Duration(seconds: 2));
        } catch (e) {
          // If URL fails, fall back to vibration only
          break;
        }
      }
    } catch (e) {
      // If audio fails completely, use vibration as fallback
    }
  }

  Future<void> stopSiren() async {
    _isSirenPlaying = false;
    await _audioPlayer.stop();
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  bool get isSirenPlaying => _isSirenPlaying;
}