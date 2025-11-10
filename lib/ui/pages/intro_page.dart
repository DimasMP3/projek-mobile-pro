import 'package:flutter/material.dart';
import '../../../config/app_routes.dart';
// PERBAIKI PATH IMPORT:
import '../widgets/custom_button.dart'; // <= benar, satu level naik ke ../widgets

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cinema-bgk.jpg',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Color(0xCC0B0F1A),
                    Color(0xE60B0F1A),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const Spacer(),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo-santix.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SanTix',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book your favorite movie tickets\nanytime, anywhere!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 140),

                  // ===== Buttons =====
                  CustomButton(
                    label: 'Masuk',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.login,
                    ), // butuh route 'login'
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    label: 'Daftar',
                    outline: true,
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.register,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
