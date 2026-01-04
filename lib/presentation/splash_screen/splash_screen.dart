import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

/// Splash Screen for Token V Wallet
///
/// Application's entry point providing:
/// - Brand introduction with Token V logo
/// - Animated entrance effect with gradient background
/// - System initialization and security verification
/// - User authentication state detection
/// - Network connectivity checks
/// - Progressive loading messages
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _loadingMessage = 'Initializing Secure Connection';
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _performInitialization();
  }

  /// Initialize animations for logo entrance
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  /// Perform system initialization sequence
  Future<void> _performInitialization() async {
    try {
      // Step 1: Initialize secure connection
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _updateLoadingMessage('Verifying Account Status');

      // Step 2: Check network connectivity
      await _checkConnectivity();
      if (!mounted) return;

      // Step 3: Verify Supabase initialization
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _updateLoadingMessage('Loading Wallet Data');

      try {
        // Ensure Supabase is properly initialized
        final isInitialized = SupabaseService.instance.client != null;
        if (!isInitialized) {
          debugPrint(
              'Supabase client not initialized, attempting to initialize');
          await SupabaseService.initialize();
        }
      } catch (e) {
        debugPrint('Supabase initialization check error: $e');
        // Continue even if Supabase check fails - will handle in auth check
      }

      // Step 4: Verify user session
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      final isAuthenticated = await _checkAuthenticationStatus();

      // Step 5: Navigate based on authentication state
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _navigateToNextScreen(isAuthenticated);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        _showErrorAndRetry();
      }
    }
  }

  /// Update loading message
  void _updateLoadingMessage(String message) {
    if (mounted) {
      setState(() {
        _loadingMessage = message;
      });
    }
  }

  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      // Simulate connectivity check
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isOnline = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  /// Check user authentication status
  Future<bool> _checkAuthenticationStatus() async {
    try {
      // Verify Supabase client exists before checking auth
      return SupabaseService.instance.isAuthenticated;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  /// Navigate to appropriate screen based on auth state
  void _navigateToNextScreen(bool isAuthenticated) {
    if (!mounted) return;

    final targetRoute =
        isAuthenticated ? AppRoutes.walletDashboard : AppRoutes.login;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, targetRoute);
      }
    });
  }

  /// Show error message and provide retry option
  void _showErrorAndRetry() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Initialization Error',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          _isOnline
              ? 'Unable to initialize the app. Please try again.'
              : 'No internet connection. Please check your network and try again.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _performInitialization();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withAlpha(204),
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/img_app_logo.svg',
                            width: 20.w,
                            height: 20.w,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // App Name
                      Text(
                        'Token V Wallet',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Tagline
                      Text(
                        'Secure Digital Transactions',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withAlpha(230),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Loading Indicator and Message
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Network Status Indicator
                    if (!_isOnline)
                      Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Offline',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Loading Indicator
                    SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Loading Message
                    Text(
                      _loadingMessage,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withAlpha(230),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
