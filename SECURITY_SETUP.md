# Security Implementation Guide

## Overview
This document provides step-by-step instructions for completing the security setup of your Token V wallet app.

## 🔐 Security Features Implemented

1. **Runtime Application Self-Protection (RASP)** - freerasp package
   - Root/jailbreak detection
   - Debugger detection
   - Emulator detection
   - Tampering detection
   - Hooking detection
   - Screen recording detection

2. **Code Obfuscation** - ProGuard (Android) / Xcode (iOS)
   - Class name obfuscation
   - Method name obfuscation
   - Resource shrinking

3. **Certificate Pinning** - Custom HTTPS client
   - SSL/TLS certificate validation
   - Protection against MITM attacks

4. **Request Signing** - HMAC-SHA256
   - API request integrity verification
   - Replay attack prevention

## 📋 Required Configuration Steps

### 1. Update freeRASP Configuration

Edit `lib/services/security_service.dart`:

```dart
androidConfig: AndroidConfig(
  packageName: 'com.token_v_wallet.app', // Your package name
  signingCertHashes: [
    'YOUR_CERT_HASH_HERE', // Get from: keytool -list -v -keystore your-release-key.keystore
  ],
),

iosConfig: IOSConfig(
  bundleIds: ['com.token-v-wallet.app'], // Your bundle ID
  teamId: 'YOUR_TEAM_ID', // Your Apple Team ID
),

watcherMail: 'security@yourapp.com', // Your security email
```

**How to get Android signing certificate hash:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**How to get Apple Team ID:**
1. Log in to https://developer.apple.com
2. Go to Membership page
3. Copy your Team ID

### 2. Configure Certificate Pinning

Edit `lib/services/supabase_service.dart`:

**Get your Supabase certificate pins:**
```bash
# Replace YOUR_PROJECT with your actual Supabase project reference
openssl s_client -connect YOUR_PROJECT.supabase.co:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

Add the output to `_certificatePins` list:
```dart
static const List<String> _certificatePins = [
  'YOUR_PRIMARY_PIN_HERE',
  'YOUR_BACKUP_PIN_HERE',
];
```

### 3. Configure Request Signing

Edit `lib/services/request_signing_service.dart`:

Generate a secure secret key:
```bash
openssl rand -base64 32
```

Add to your environment variables:
```dart
// In your flutter run command:
flutter run --dart-define=API_SECRET_KEY=your-generated-secret-key
```

### 4. Configure Environment Variables

Create a `.env` file or use `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your-supabase-url \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=API_SECRET_KEY=your-secret-key
```

For production builds:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=your-supabase-url \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=API_SECRET_KEY=your-secret-key
```

### 5. Update ProGuard Rules (Android)

The ProGuard rules are already configured in `android/app/proguard-rules.pro`.

Update the model package name if different:
```proguard
-keep class com.token_v_wallet.app.models.** { *; }
```

### 6. Configure iOS Security

Edit `ios/Runner/Info.plist` to add security configurations:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>supabase.co</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## 🛡️ Security Best Practices

### 1. Handle Security Threats

Update threat handlers in `lib/services/security_service.dart`:

```dart
void _handleRootJailbreakDetection() {
  // Example: Force logout and show warning
  SupabaseService.instance.logout();
  // Show security warning dialog
  // Disable sensitive features
}
```

### 2. Use Request Signing

Example of using request signing in API calls:

```dart
import '../services/request_signing_service.dart';

Future<void> makeSecureRequest() async {
  final path = '/api/transactions';
  final body = jsonEncode({'amount': 100});
  
  final headers = RequestSigningService.instance.getSignatureHeaders(
    method: 'POST',
    path: path,
    body: body,
  );
  
  // Add headers to your HTTP request
  final response = await dio.post(
    path,
    data: body,
    options: Options(headers: headers),
  );
}
```

### 3. Monitor Security Status

Check security status in your app:

```dart
import '../services/security_service.dart';

bool isSecure = SecurityService.instance.isDeviceSecure;
String status = SecurityService.instance.securityStatus;

if (!isSecure) {
  // Handle insecure device
  // Show warning or restrict features
}
```

### 4. Build for Production

Always use release mode with obfuscation enabled:

```bash
# Android
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# iOS
flutter build ios --release --obfuscate --split-debug-info=build/ios/symbols
```

## 🧪 Testing Security Features

### Test Root/Jailbreak Detection
1. Run app on rooted/jailbroken device
2. Check logs for "Device is rooted/jailbroken"
3. Verify app handles it appropriately

### Test Debugger Detection
1. Attach debugger to running app
2. Check logs for "Debugger detected"
3. Verify app responds to threat

### Test Certificate Pinning
1. Use proxy tool (Charles, Burp Suite)
2. Try to intercept HTTPS traffic
3. Verify connection fails with pinning error

### Test Request Signing
1. Make API request without signature
2. Verify request is rejected
3. Make request with valid signature
4. Verify request succeeds

## 📊 Security Monitoring

Monitor security events:

```dart
// In your app
SecurityService.instance.initialize();

// Check status
if (!SecurityService.instance.isDeviceSecure) {
  // Send alert to backend
  // Log security event
  // Take appropriate action
}
```

## 🚨 Important Security Notes

1. **Never commit secrets to Git**
   - Use environment variables
   - Use secure secret management
   - Rotate keys regularly

2. **Keep dependencies updated**
   - Regularly update freerasp
   - Update crypto packages
   - Monitor security advisories

3. **Test thoroughly**
   - Test on real devices
   - Test all security features
   - Perform penetration testing

4. **Monitor in production**
   - Log security events
   - Set up alerts
   - Review security logs regularly

5. **Comply with regulations**
   - Follow PCI DSS for payments
   - Comply with GDPR for data
   - Follow local financial regulations

## 📞 Support

For security concerns:
- Email: security@yourapp.com
- Review threat handlers in SecurityService
- Check freeRASP documentation: https://github.com/talsec/Free-RASP-Flutter

## 🔄 Regular Maintenance

- [ ] Rotate API secret keys every 90 days
- [ ] Update certificate pins when SSL cert changes
- [ ] Review and update ProGuard rules
- [ ] Test security features after each release
- [ ] Monitor security threat logs weekly
- [ ] Update dependencies monthly