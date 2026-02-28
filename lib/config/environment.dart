import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  // API and Socket URLs: read from .env with production fallbacks.
  // For local dev: copy .env.example to .env and set API_BASE_URL and SOCKET_URL to your local backend (e.g. http://localhost:4000/api, http://localhost:4000).
  // For physical device on same network: use your machine IP (e.g. http://192.168.x.x:4000/api).
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://inkbattle.in/api';
  static String get socketUrl =>
      dotenv.env['SOCKET_URL'] ?? 'https://inkbattle.in';

  static const String appSecret = "InkBattle_Secure_2024"; // match Nginx exactly
  static const int dailyCoinsAwarded = 1000;

  // Razorpay Configuration (from .env) - uncomment when needed
  // static String get razorpayKeyId =>
  //     dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_RaT4OZ1pgy4cJb';
  // static String get razorpayKeySecret =>
  //     dotenv.env['RAZORPAY_KEY_SECRET'] ?? 'szRFADGHws42Er26s5sg7ro1';
  // static int get paymentAmount =>
  //     int.tryParse(dotenv.env['PAYMENT_AMOUNT'] ?? '1000') ?? 1000;
  // static int get coinsOnPayment =>
  //     int.tryParse(dotenv.env['COINS_ON_PAYMENT'] ?? '8000') ?? 8000;
  static String get agoraAppId =>
      dotenv.env['AGORA_APP_ID'] ?? '85ed3bccf4dc4f62b3e30b834a0b5670';

  // Web client ID (OAuth 2.0) from Firebase/Google Cloud. Required for Google Sign-In idToken on Android.
  // static String get googleWebClientId =>
  //     dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
  //     '810403540241-ip9gtcb25f8m6f3du23riuqj5h5dbr9l.apps.googleusercontent.com';
}
