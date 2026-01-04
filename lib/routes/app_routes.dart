import 'package:flutter/material.dart';

import '../presentation/admin_dashboard/admin_dashboard.dart';
import '../presentation/bank_account_verification/bank_account_verification.dart';
import '../presentation/checkout_screen/checkout_screen.dart';
import '../presentation/developer_settings/developer_settings.dart';
import '../presentation/ledger_analytics_panel/ledger_analytics_panel.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/payment_methods/payment_methods.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/send_credits/send_credits.dart';
import '../presentation/spending_limits/spending_limits_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/transaction_receipt/transaction_receipt.dart';
import '../presentation/trusted_devices/trusted_devices_screen.dart';
import '../presentation/two_factor_setup/two_factor_setup_screen.dart';
import '../presentation/two_factor_verify/two_factor_verify_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/wallet_dashboard/wallet_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String walletDashboard = '/wallet-dashboard';
  static const String login = '/login-screen';
  static const String transactionHistory = '/transaction-history';
  static const String sendCredits = '/send-credits';
  static const String userRegistration = '/user-registration';
  static const String adminDashboard = '/admin-dashboard';
  static const String profileScreen = '/profile-screen';
  static const String checkoutScreen = '/checkout-screen';
  static const String transactionReceipt = '/transaction-receipt';
  static const String twoFactorSetup = '/two-factor-setup';
  static const String twoFactorVerify = '/two-factor-verify';
  static const String trustedDevices = '/trusted-devices';
  static const String spendingLimits = '/spending-limits';
  static const String ledgerAnalyticsPanel = '/ledger-analytics-panel';
  static const String paymentMethods = '/payment-methods';
  static const String bankAccountVerification = '/bank-account-verification';
  static const String developerSettings = '/developer-settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (context) => const SplashScreen(),
      splashScreen: (context) => const SplashScreen(),
      walletDashboard: (context) => const WalletDashboard(),
      login: (context) => const LoginScreen(),
      transactionHistory: (context) => const TransactionHistory(),
      sendCredits: (context) => const SendCredits(),
      userRegistration: (context) => const UserRegistration(),
      adminDashboard: (context) => const AdminDashboard(),
      profileScreen: (context) => const ProfileScreen(),
      checkoutScreen: (context) => const CheckoutScreen(),
      transactionReceipt: (context) => const TransactionReceipt(),
      twoFactorSetup: (context) => const TwoFactorSetupScreen(),
      twoFactorVerify: (context) => const TwoFactorVerifyScreen(),
      trustedDevices: (context) => const TrustedDevicesScreen(),
      spendingLimits: (context) => const SpendingLimitsScreen(),
      ledgerAnalyticsPanel: (context) => const LedgerAnalyticsPanel(),
      paymentMethods: (context) => PaymentMethodsScreen(),
      bankAccountVerification: (context) => BankAccountVerificationScreen(),
      developerSettings: (context) => const DeveloperSettingsScreen(),
    };
  }
}
