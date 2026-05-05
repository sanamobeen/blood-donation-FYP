import 'package:shared_preferences/shared_preferences.dart';

class SOSRateLimiter {
  static final SOSRateLimiter _instance = SOSRateLimiter._internal();
  factory SOSRateLimiter() => _instance;
  SOSRateLimiter._internal();

  static const int maxActivationsPerHour = 3;
  static const int maxActivationsPerDay = 5;
  static const int cooldownMinutes = 30;

  Future<bool> canActivateSOS() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final hourlyCount = prefs.getInt('sos_hourly_count') ?? 0;
    final dailyCount = prefs.getInt('sos_daily_count') ?? 0;
    final lastActivation = prefs.getString('sos_last_activation');

    if (lastActivation != null) {
      final lastActivationTime = DateTime.parse(lastActivation);
      final minutesSinceLastActivation = now.difference(lastActivationTime).inMinutes;

      if (minutesSinceLastActivation < cooldownMinutes) {
        final remainingMinutes = cooldownMinutes - minutesSinceLastActivation;
        throw SOSRateLimitException(
          'Please wait $remainingMinutes minutes before activating SOS again',
          remainingMinutes: remainingMinutes,
        );
      }
    }

    final lastHourlyReset = prefs.getString('sos_hourly_reset');
    if (lastHourlyReset != null) {
      final lastReset = DateTime.parse(lastHourlyReset);
      if (now.difference(lastReset).inHours >= 1) {
        await prefs.setInt('sos_hourly_count', 0);
        await prefs.setString('sos_hourly_reset', now.toIso8601String());
      }
    } else {
      await prefs.setString('sos_hourly_reset', now.toIso8601String());
    }

    final lastDailyReset = prefs.getString('sos_daily_reset');
    if (lastDailyReset != null) {
      final lastReset = DateTime.parse(lastDailyReset);
      if (now.difference(lastReset).inHours >= 24) {
        await prefs.setInt('sos_daily_count', 0);
        await prefs.setString('sos_daily_reset', now.toIso8601String());
      }
    } else {
      await prefs.setString('sos_daily_reset', now.toIso8601String());
    }

    if (hourlyCount >= maxActivationsPerHour) {
      throw SOSRateLimitException(
        'Too many activations. Maximum $maxActivationsPerHour per hour',
      );
    }

    if (dailyCount >= maxActivationsPerDay) {
      throw SOSRateLimitException(
        'Too many activations. Maximum $maxActivationsPerDay per day. Please contact support if this is a real emergency.',
      );
    }

    return true;
  }

  Future<void> recordSOSActivation() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final hourlyCount = prefs.getInt('sos_hourly_count') ?? 0;
    final dailyCount = prefs.getInt('sos_daily_count') ?? 0;

    await prefs.setInt('sos_hourly_count', hourlyCount + 1);
    await prefs.setInt('sos_daily_count', dailyCount + 1);
    await prefs.setString('sos_last_activation', now.toIso8601String());

    final history = prefs.getStringList('sos_activation_history') ?? [];
    history.add(now.toIso8601String());
    await prefs.setStringList('sos_activation_history', history);
  }

  Future<void> recordSOSCancellation() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final history = prefs.getStringList('sos_cancellation_history') ?? [];
    history.add(now.toIso8601String());
    await prefs.setStringList('sos_cancellation_history', history);
  }

  Future<Map<String, dynamic>> getUsageStats() async {
    final prefs = await SharedPreferences.getInstance();

    final activations = prefs.getStringList('sos_activation_history') ?? [];
    final cancellations = prefs.getStringList('sos_cancellation_history') ?? [];

    return {
      'total_activations': activations.length,
      'total_cancellations': cancellations.length,
      'hourly_count': prefs.getInt('sos_hourly_count') ?? 0,
      'daily_count': prefs.getInt('sos_daily_count') ?? 0,
      'max_hourly': maxActivationsPerHour,
      'max_daily': maxActivationsPerDay,
    };
  }
}

class SOSRateLimitException implements Exception {
  final String message;
  final int? remainingMinutes;

  SOSRateLimitException(this.message, {this.remainingMinutes});

  @override
  String toString() => message;
}