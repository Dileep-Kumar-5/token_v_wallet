import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './routes/app_routes.dart';
import './services/payment_service.dart';
import './services/supabase_service.dart';
import './theme/app_theme.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production, log errors silently
      debugPrint('Flutter Error: ${details.exception}');
    }
  };

  // Add PlatformDispatcher error handler for async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Async error: $error\nStack trace: $stack');
    }
    return true; // Return true to prevent the error from propagating
  };

  try {
    // Initialize Supabase with timeout and better error handling
    await SupabaseService.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          print('Supabase initialization timed out');
        }
        throw Exception('Supabase initialization timeout');
      },
    );

    if (kDebugMode) {
      print('Supabase initialized successfully');
    }

    // Initialize Stripe (optional, continue if fails)
    try {
      await PaymentService.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print('Stripe initialization timed out');
          }
        },
      );
      if (kDebugMode) {
        print('Stripe initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization failed: $e');
      }
      // Continue app launch - Stripe is optional
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('App initialization failed: $e');
      print('Stack trace: $stackTrace');
    }

    // Show error screen if critical initialization fails
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kDebugMode
                      ? 'Error: ${e.toString()}\n\nPlease check your internet connection and try again.'
                      : 'Please check your internet connection and try again.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Attempt to restart by reloading the app
                    // Note: This will work in web, but may not work as expected in native
                    if (kIsWeb) {
                      // For web, we can use window.location.reload()
                      // but need to import dart:html conditionally
                    } else {
                      // For native, we need to restart the entire app
                      SystemNavigator.pop(); // Exit the app
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Token V Wallet',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          // Add error widget override for better error display
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kDebugMode
                            ? details.exception.toString()
                            : 'Something went wrong',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          };

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
        // Add unknown route handler
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                title: const Text('Not Found'),
                backgroundColor: Colors.black,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Page Not Found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route: ${settings.name}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.initial,
                          (route) => false,
                        );
                      },
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}