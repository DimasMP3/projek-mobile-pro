import 'package:jwt_decode/jwt_decode.dart';

class Session {
  static String? _token;
  static String? _email;
  static String? _name;

  static String? get token => _token;
  static String? get email => _email;
  static String? get name => _name;

  static void setToken(String token) {
    _token = token;
    try {
      final payload = Jwt.parseJwt(token);
      _email = payload['email']?.toString();
      _name = payload['name']?.toString();
    } catch (_) {
      _email = null;
      _name = null;
    }
  }

  static void clear() {
    _token = null;
    _email = null;
    _name = null;
  }
}

