import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class to manage environment variables
class EnvConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
      if (kDebugMode) {
        print('Environment variables loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading environment variables: $e');
      }
    }
  }

  /// API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '60') ?? 60;

  /// App Information
  static String get appName => dotenv.env['APP_NAME'] ?? 'Smart Shop';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// Stripe Configuration
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
}
