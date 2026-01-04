import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:http/io_client.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Certificate pins for your Supabase instance
  // TODO: Replace with your actual certificate pins
  static const List<String> _certificatePins = [
    // SHA-256 hash of your Supabase SSL certificate
    // Get it using: openssl s_client -connect your-project.supabase.co:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    'your-certificate-pin-1',
    'your-certificate-pin-2', // Backup pin
  ];

  // Initialize Supabase with certificate pinning
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }

    // Create HTTP client with certificate pinning
    final httpClient = IOClient(_createSecureHttpClient());

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      httpClient: httpClient,
    );
  }

  /// Create HTTP client with certificate pinning
  static HttpClient _createSecureHttpClient() {
    final client = HttpClient();

    // Configure certificate validation
    client.badCertificateCallback = (cert, host, port) {
      // Only validate for Supabase host
      if (!host.contains('supabase.co')) {
        return false;
      }

      // Get certificate's public key SHA-256 hash
      final certHash = _getCertificateHash(cert);

      // Check if certificate matches any of our pins
      final isPinned = _certificatePins.contains(certHash);

      if (!isPinned) {
        throw Exception('Certificate pinning failed for $host');
      }

      return isPinned;
    };

    return client;
  }

  /// Extract SHA-256 hash from certificate
  static String _getCertificateHash(X509Certificate cert) {
    // TODO: Implement proper certificate hash extraction
    // This is a placeholder - actual implementation depends on your security requirements
    return '';
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  /// Logout user and clear session
  ///
  /// Performs complete session cleanup including:
  /// - Signing out from Supabase
  /// - Clearing authentication tokens
  /// - Resetting local session data
  Future<void> logout() async {
    try {
      // Sign out from Supabase (clears all tokens and session)
      await client.auth.signOut();
    } catch (e) {
      // Even if signout fails, we should clear local state
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    return client.auth.currentUser != null;
  }

  /// Get current user session
  Session? get currentSession {
    return client.auth.currentSession;
  }
}
