import 'package:flutter/material.dart';

// === Import semua halaman yang digunakan ===
import '../ui/pages/splash_page.dart';
import '../ui/pages/onboarding_page.dart';
import '../ui/pages/intro_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/register_page.dart';
import '../ui/pages/reset_password_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/movie_detail_page.dart';
import '../ui/pages/seat_selection_page.dart';
import '../ui/pages/payment_page.dart';
import '../ui/pages/ticket_page.dart';
import '../ui/pages/now_showing_page.dart';
import '../ui/pages/search_page.dart';
import '../ui/pages/fun_page.dart';
import '../ui/pages/cinemas_page.dart';
import '../ui/pages/account_page.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const intro = '/intro';
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset';
  static const home = '/home';
  static const detail = '/detail';
  static const seats = '/seats';
  static const payment = '/payment';
  static const ticket = '/ticket';
  static const nowShowing = '/now-showing';
  static const search = '/search';
  static const fun = '/fun';
  static const cinemas = '/cinemas';
  static const account = '/account';

  static Route onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:
        return _fade(const SplashPage());
      case onboarding:
        return _fade(const OnboardingPage());
      case intro:
        return _fade(const IntroPage());
      case login:
        return _fade(const LoginPage());
      case register:
        return _fade(const RegisterPage());
      case resetPassword:
        return _fade(const ResetPasswordPage());
      case home:
        return _fade(const HomePage());
      case detail:
        return _fade(MovieDetailPage(movieId: s.arguments as String));
      case seats:
        final args = s.arguments;
        if (args is Map) {
          return _fade(
            SeatSelectionPage(
              movieId: args['movieId'] as String,
              time: args['time'] as DateTime?,
              cinema: args['cinema'] as String?,
            ),
          );
        } else {
          return _fade(SeatSelectionPage(movieId: args as String));
        }
      case payment:
        return _fade(const PaymentPage());
      case ticket:
        return _fade(const TicketPage());
      case nowShowing:
        return _fade(const NowShowingPage());
      case search:
        return _fade(const SearchPage());
      case fun:
        return _fade(const FunPage());
      case cinemas:
        return _fade(const CinemasPage());
      case account:
        return _fade(const AccountPage());
      default:
        return _fade(const SplashPage());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    transitionDuration: const Duration(milliseconds: 250),
  );
}
