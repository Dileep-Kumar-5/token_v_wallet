import 'dart:math';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Two-Factor Authentication Service
/// Manages TOTP-based 2FA setup and verification
class TwoFactorAuthService {
  static const String _keySecret = 'totp_secret';
  static const String _keyEnabled = '2fa_enabled';
  static const String _keyBackupCodes = 'backup_codes';

  /// Generate a new TOTP secret for user enrollment
  static String generateSecret() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final Random random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Save TOTP secret to secure storage
  static Future<void> saveSecret(String secret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySecret, secret);
    await prefs.setBool(_keyEnabled, true);
  }

  /// Get saved TOTP secret
  static Future<String?> getSecret() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySecret);
  }

  /// Check if 2FA is enabled
  static Future<bool> is2FAEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  /// Disable 2FA
  static Future<void> disable2FA() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySecret);
    await prefs.setBool(_keyEnabled, false);
    await prefs.remove(_keyBackupCodes);
  }

  /// Generate TOTP code for current time
  static String generateTOTPCode(String secret) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  }

  /// Verify TOTP code
  static bool verifyTOTPCode(String secret, String code) {
    final currentCode = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    // Also check previous and next time windows for clock skew
    final prevCode = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch - 30000,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final nextCode = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch + 30000,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    return code == currentCode || code == prevCode || code == nextCode;
  }

  /// Generate backup codes for account recovery
  static Future<List<String>> generateBackupCodes() async {
    final List<String> codes = [];
    final Random random = Random.secure();

    for (int i = 0; i < 8; i++) {
      String code = '';
      for (int j = 0; j < 8; j++) {
        code += random.nextInt(10).toString();
      }
      codes.add('${code.substring(0, 4)}-${code.substring(4)}');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyBackupCodes, codes);

    return codes;
  }

  /// Verify backup code and remove it after use
  static Future<bool> verifyBackupCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? codes = prefs.getStringList(_keyBackupCodes);

    if (codes == null || !codes.contains(code)) {
      return false;
    }

    codes.remove(code);
    await prefs.setStringList(_keyBackupCodes, codes);
    return true;
  }

  /// Get authenticator URI for QR code
  static String getAuthenticatorUri(String secret, String email) {
    return 'otpauth://totp/TokenV:$email?secret=$secret&issuer=TokenV&algorithm=SHA1&digits=6&period=30';
  }
}
