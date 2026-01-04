import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Request signing service for API security
/// Implements HMAC-SHA256 signature verification for all API requests
class RequestSigningService {
  static RequestSigningService? _instance;
  static RequestSigningService get instance =>
      _instance ??= RequestSigningService._();

  RequestSigningService._();

  // Secret key for HMAC signing - MUST be stored securely
  // TODO: Load from secure storage or environment variable
  static const String _secretKey =
      String.fromEnvironment('API_SECRET_KEY', defaultValue: '');

  /// Generate HMAC-SHA256 signature for request
  ///
  /// Parameters:
  /// - timestamp: Current timestamp in milliseconds
  /// - method: HTTP method (GET, POST, etc.)
  /// - path: API endpoint path
  /// - body: Optional request body as JSON string
  ///
  /// Returns: Base64 encoded signature
  String generateSignature({
    required int timestamp,
    required String method,
    required String path,
    String? body,
  }) {
    if (_secretKey.isEmpty) {
      throw Exception('API_SECRET_KEY not configured');
    }

    // Create signing string: timestamp|method|path|body
    final signingString = [
      timestamp.toString(),
      method.toUpperCase(),
      path,
      body ?? '',
    ].join('|');

    // Generate HMAC-SHA256
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(signingString);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);

    // Return base64 encoded signature
    return base64.encode(digest.bytes);
  }

  /// Verify signature for incoming requests
  ///
  /// Parameters:
  /// - signature: The signature to verify
  /// - timestamp: Timestamp used in signature
  /// - method: HTTP method
  /// - path: API endpoint path
  /// - body: Optional request body
  /// - maxAge: Maximum age of request in seconds (default: 300)
  ///
  /// Returns: true if signature is valid and timestamp is fresh
  bool verifySignature({
    required String signature,
    required int timestamp,
    required String method,
    required String path,
    String? body,
    int maxAge = 300,
  }) {
    // Check timestamp freshness (prevent replay attacks)
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = (now - timestamp) ~/ 1000; // Convert to seconds

    if (age > maxAge) {
      return false; // Request too old
    }

    // Generate expected signature
    final expectedSignature = generateSignature(
      timestamp: timestamp,
      method: method,
      path: path,
      body: body,
    );

    // Constant-time comparison to prevent timing attacks
    return _secureCompare(signature, expectedSignature);
  }

  /// Secure string comparison (constant time)
  /// Prevents timing attacks by always comparing all characters
  bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Add signature headers to HTTP request
  ///
  /// Returns map of headers to add to request
  Map<String, String> getSignatureHeaders({
    required String method,
    required String path,
    String? body,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final signature = generateSignature(
      timestamp: timestamp,
      method: method,
      path: path,
      body: body,
    );

    return {
      'X-Timestamp': timestamp.toString(),
      'X-Signature': signature,
    };
  }
}
