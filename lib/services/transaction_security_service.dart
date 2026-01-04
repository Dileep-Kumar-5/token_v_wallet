import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Transaction Security Service
/// Monitors and validates transaction patterns for fraud detection
class TransactionSecurityService {
  static const String _keyDailyLimit = 'daily_spending_limit';
  static const String _keyMonthlyLimit = 'monthly_spending_limit';
  static const String _keyLastTransactionTime = 'last_transaction_time';
  static const String _keyTransactionCount = 'transaction_count_today';
  static const String _keyTrustedDevices = 'trusted_devices';
  static const String _keyDeviceId = 'current_device_id';

  /// Default spending limits
  static const double defaultDailyLimit = 1000.0;
  static const double defaultMonthlyLimit = 5000.0;

  /// Velocity checking thresholds
  static const int maxTransactionsPerHour = 10;
  static const int maxTransactionsPerDay = 50;
  static const Duration rapidTransactionThreshold = Duration(minutes: 2);

  /// Get daily spending limit
  static Future<double> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDailyLimit) ?? defaultDailyLimit;
  }

  /// Set daily spending limit
  static Future<void> setDailyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDailyLimit, limit);
  }

  /// Get monthly spending limit
  static Future<double> getMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyLimit) ?? defaultMonthlyLimit;
  }

  /// Set monthly spending limit
  static Future<void> setMonthlyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyLimit, limit);
  }

  /// Check if transaction amount exceeds limits
  static Future<TransactionValidationResult> validateTransactionAmount(
      double amount) async {
    final dailyLimit = await getDailyLimit();
    final monthlyLimit = await getMonthlyLimit();

    if (amount > dailyLimit) {
      return TransactionValidationResult(
        isValid: false,
        requiresBiometric: true,
        reason: 'Transaction amount exceeds daily limit of \$$dailyLimit',
      );
    }

    if (amount > monthlyLimit) {
      return TransactionValidationResult(
        isValid: false,
        requiresBiometric: true,
        reason: 'Transaction amount exceeds monthly limit of \$$monthlyLimit',
      );
    }

    // High-value transactions require additional verification
    if (amount > 500) {
      return TransactionValidationResult(
        isValid: true,
        requiresBiometric: true,
        reason: 'High-value transaction requires biometric verification',
      );
    }

    return TransactionValidationResult(isValid: true);
  }

  /// Velocity checking - detect rapid transactions
  static Future<TransactionValidationResult> checkVelocity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTransactionTime = prefs.getInt(_keyLastTransactionTime) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final transactionCount = prefs.getInt(_keyTransactionCount) ?? 0;

    // Check if transaction is too rapid
    if (lastTransactionTime > 0) {
      final timeSinceLastTransaction =
          Duration(milliseconds: currentTime - lastTransactionTime);

      if (timeSinceLastTransaction < rapidTransactionThreshold) {
        return TransactionValidationResult(
          isValid: false,
          requiresBiometric: true,
          reason:
              'Rapid transaction detected. Please wait ${rapidTransactionThreshold.inSeconds} seconds between transactions.',
          delayRequired: rapidTransactionThreshold - timeSinceLastTransaction,
        );
      }
    }

    // Check transaction count
    if (transactionCount >= maxTransactionsPerHour) {
      return TransactionValidationResult(
        isValid: false,
        requiresBiometric: true,
        reason:
            'Transaction limit reached. Maximum $maxTransactionsPerHour transactions per hour.',
      );
    }

    // Update transaction tracking
    await prefs.setInt(_keyLastTransactionTime, currentTime);
    await prefs.setInt(_keyTransactionCount, transactionCount + 1);

    return TransactionValidationResult(isValid: true);
  }

  /// Reset daily transaction counter (call at midnight)
  static Future<void> resetDailyCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTransactionCount);
  }

  /// Detect suspicious patterns
  static Future<TransactionValidationResult> detectSuspiciousPattern({
    required double amount,
    required String recipientId,
    required String location,
  }) async {
    final List<String> suspiciousIndicators = [];

    // Check for round numbers (common in fraud)
    if (amount % 100 == 0 && amount >= 500) {
      suspiciousIndicators.add('Round amount transaction');
    }

    // Check for unusual location (simplified - in production use geolocation)
    // This would compare with user's typical transaction locations
    if (location.toLowerCase().contains('foreign') ||
        location.toLowerCase().contains('international')) {
      suspiciousIndicators.add('Unusual location detected');
    }

    if (suspiciousIndicators.isNotEmpty) {
      return TransactionValidationResult(
        isValid: true,
        requiresBiometric: true,
        reason:
            'Suspicious pattern detected: ${suspiciousIndicators.join(", ")}. Additional verification required.',
      );
    }

    return TransactionValidationResult(isValid: true);
  }

  /// Add device to trusted devices
  static Future<void> addTrustedDevice(
      String deviceId, String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> devices = prefs.getStringList(_keyTrustedDevices) ?? [];
    final deviceInfo =
        '$deviceId:$deviceName:${DateTime.now().toIso8601String()}';

    if (!devices.any((d) => d.startsWith(deviceId))) {
      devices.add(deviceInfo);
      await prefs.setStringList(_keyTrustedDevices, devices);
    }
  }

  /// Check if current device is trusted
  static Future<bool> isDeviceTrusted(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> devices = prefs.getStringList(_keyTrustedDevices) ?? [];
    return devices.any((d) => d.startsWith(deviceId));
  }

  /// Get current device ID
  static Future<String> getCurrentDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null) {
      // Generate unique device ID
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }

  /// Remove trusted device
  static Future<void> removeTrustedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> devices = prefs.getStringList(_keyTrustedDevices) ?? [];
    devices.removeWhere((d) => d.startsWith(deviceId));
    await prefs.setStringList(_keyTrustedDevices, devices);
  }

  /// Get all trusted devices
  static Future<List<TrustedDevice>> getTrustedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> devices = prefs.getStringList(_keyTrustedDevices) ?? [];

    return devices.map((deviceInfo) {
      final parts = deviceInfo.split(':');
      return TrustedDevice(
        id: parts[0],
        name: parts.length > 1 ? parts[1] : 'Unknown Device',
        addedDate: parts.length > 2 ? DateTime.parse(parts[2]) : DateTime.now(),
      );
    }).toList();
  }
}

/// Transaction validation result
class TransactionValidationResult {
  final bool isValid;
  final bool requiresBiometric;
  final String? reason;
  final Duration? delayRequired;

  TransactionValidationResult({
    required this.isValid,
    this.requiresBiometric = false,
    this.reason,
    this.delayRequired,
  });
}

/// Trusted device model
class TrustedDevice {
  final String id;
  final String name;
  final DateTime addedDate;

  TrustedDevice({
    required this.id,
    required this.name,
    required this.addedDate,
  });
}
