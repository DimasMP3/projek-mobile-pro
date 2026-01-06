import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/api_client.dart';
import '../core/env.dart';
import 'session.dart';

class AuthService {
  static GoogleSignIn? _google;

static GoogleSignIn _googleInstance() {
  return _google ??= GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: AppEnv.googleWebClientId.isNotEmpty
        ? AppEnv.googleWebClientId
        : null,
  );
}

  // Native Google Sign-In flow
  static Future<String?> loginWithGoogle() async {
    try {
      final google = _googleInstance();
      final account = await google.signIn();
      if (account == null) {
        debugPrint('Google sign-in cancelled by user.');
        return null;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        debugPrint('Google sign-in failed: missing idToken.');
        return null;
      }

      final response = await ApiClient.dio.post(
        '${AppEnv.apiBaseUrl}/api/auth/google',
        data: {'idToken': idToken},
      );
      final data = response.data;
      String? token;
      if (data is Map) {
        if (data['token'] != null) {
          token = data['token']?.toString();
        } else if (data['data'] is Map && data['data']['token'] != null) {
          token = data['data']['token']?.toString();
        }
      }
      if (token == null || token.isEmpty) {
        debugPrint('Backend did not return token.');
        return null;
      }

      ApiClient.setAuthToken(token);
      Session.setToken(token);
      return token;
    } catch (e, stack) {
      debugPrint('Google sign-in error: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  static Future<void> logout() async {
    final google = _googleInstance();
    await google.signOut();
    ApiClient.setAuthToken(null);
    Session.clear();
  }
}
