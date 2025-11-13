import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']?.trim() ?? '';
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '';
}
